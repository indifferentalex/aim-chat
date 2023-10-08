class WaterworldController < ApplicationController

    def index
        if !current_chat || params[:new_session]
            @chat = WaterworldChat.create!(
                metadata: {
                    water_intake: 0,
                },
            )

            # Clears the params
            redirect_to waterworld_path
        else
            @chat = current_chat
        end
    end

    def process_message
        chat = WaterworldChat.find(params[:chat_id])

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
        WaterworldChat.order(:created_at).last
    end

end