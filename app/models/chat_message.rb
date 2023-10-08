class ChatMessage < ApplicationRecord
    belongs_to :chat

    # For use by us
    def to_json
      {
        id: id,
        role: role,
        content: content,
        name: name,
        function_call: function_call,
      }
    end

    # Formatted to satisfy the OpenAI API
    def to_openai_json
      {
        role: role,
        content: content, # Key must always be present
      }.merge(
        # Will only be present if the message is a function call,
        # hence the #compact to remove them otherwise
        {
          name: name,
          function_call: function_call,
        }.compact,
      )
    end
end