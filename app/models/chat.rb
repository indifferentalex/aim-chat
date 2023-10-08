##
# Currently built to strictly to adhere to an OpenAI ChatGPT-like structure
# (messages with roles and potentially functions to call).
class Chat < ApplicationRecord
    has_many :chat_messages, dependent: :destroy

    # OPENAI_MODEL = "gpt-4"
    OPENAI_MODEL = "gpt-3.5-turbo"
    PROMPT = "You are a helpful assistant."

    MESSAGES_CONTEXT_LENGTH = 5
    INCLUDE_FUNCTIONS_IN_CONTEXT_COUNT = false # TODO: implement in #latest_messages

    MAX_ITERATIONS = 5

    # N.B. functions must return strings (an explanation of the outcome of the
    # function call that ChatGPT can interpret and adapt into a response).
    AVAILABLE_FUNCTIONS = []
    AVAILABLE_FUNCTION_DESCRIPTIONS = nil

    PARAMETER_GENERATION_PROMPTS = {}

    def process_messages(current_messages = [], iteration_count = 0)
      if iteration_count >= self.class::MAX_ITERATIONS
        return { error: "Error: please reload the page and try again." }
      end

      messages = [
        {
            role: "system",
            content: prompt,
        },
        *latest_messages.map(&:to_openai_json),
        *current_messages,
      ]

      openai_response = HTTParty.post(
        "https://api.openai.com/v1/chat/completions",
        headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{ENV["OPENAI_KEY"]}"
        },
        body: {
            model: self.class::OPENAI_MODEL,
            messages: messages,
            functions: available_function_descriptions.presence,
        }.compact.to_json,
      )

      response_message = openai_response.dig("choices", 0, "message")

      # There's a function to call, or there is a message, or there is an error
      if response_message&.fetch("function_call", nil)
        function_response_message = execute_function_call(response_message)

        return process_messages(
          current_messages + [
            # This is the OpenAI message requesting that the function be called,
            # it's crucial that we save it both for our own purposes (for example
            # to display that the function call was requested) and so that we can
            # use it in subsequent OpenAI calls to show it that it had previously
            # requested that specific function call.
            response_message.transform_keys(&:to_sym),
            function_response_message,
          ],
          iteration_count + 1,
        )
      elsif response_message&.fetch("content", nil)
        normal_response = response_message.fetch("content")

        current_messages.push({ role: "assistant", content: normal_response })

        current_messages.each do |message|
          ChatMessage.create!(
            chat: self,
            content: message[:content],
            role: message[:role],
            name: message[:name],
            function_call: message[:function_call],
          )
        end

        return to_json
      else
        return { error: "Error: please reload the page and try again." }
      end
    end

    def to_json
      {
        chat_id: id,
        messages: chat_messages.order(:created_at).map(&:to_json),
        metadata: metadata,
      }
    end

    private

    def execute_function_call(response_message)
      function_call_request = response_message.fetch("function_call")

      function_execution_response = nil

      function_name = function_call_request.fetch("name")

      begin
        function_parameters = JSON.parse(
          function_call_request["arguments"],
          { symbolize_names: true },
        )
      rescue
        function_execution_response = "Error: invalid function parameters."
      end

      if function_execution_response.nil?
        if available_functions.include?(function_name)
          function_execution_response = send(function_name, **function_parameters)
        else
          function_execution_response = "Error: no such function found."
        end
      end

      {
        role: "function",
        name: function_name,
        content: function_execution_response,
      }
    end

    def latest_messages
      chat_messages.order(:created_at).last(self.class::MESSAGES_CONTEXT_LENGTH)
    end

    def prompt
      self.class::PROMPT
    end

    def available_functions
      self.class::AVAILABLE_FUNCTIONS
    end

    def available_function_descriptions
      self.class::AVAILABLE_FUNCTION_DESCRIPTIONS || nil
    end
end
