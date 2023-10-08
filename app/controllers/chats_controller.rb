class ChatsController < ApplicationController

    def index
        if !current_chat || params[:new_session]
            @chat = Chat.create!(
                metadata: {},
            )

            # Clears the params
            redirect_to chat_path
        else
            @chat = current_chat
        end
    end

    def show
        chat = Chat.find(params[:id])

        render json: chat.to_json
    end

    def process_message
        chat = Chat.find(params[:chat_id])

        unless chat
            render(
                json: { error: "Chat not found" },
                status: :not_found,
            ) and return
        end

        response = chat.process_messages([
            {
                role: "user",
                content: params[:message],
            }
        ])

        if response[:error]
            render(
                json: {
                    error: "Error: please reload the page and try again."
                },
                status: :internal_server_error,
            ) and return
        else
            return render json: response
        end
    end

    private

    def current_chat
        Chat.order(:created_at).last
    end

end