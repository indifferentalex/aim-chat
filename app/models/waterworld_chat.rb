class WaterworldChat < Chat

    PROMPT = "You are an assistant helping the user track their water drinking "\
        "habits. The user is trying to drink 2l of water a day. Be enthusiastic "\
        "and encouraging."

    AVAILABLE_FUNCTIONS = ["add_water"]

    AVAILABLE_FUNCTION_DESCRIPTIONS = [
        {
            name: "add_water",
            description: "Adds the specified amount of water in ml to the user's "\
                "water intake for the day.",
            parameters: {
                type: "object",
                properties: {
                    amount: {
                        type: "integer",
                        description: "The amount of water in ml to add to the user's "\
                            "water intake for the day.",
                    }
                },
                required: ["amount"],
            }
        }
    ]

    def add_water(amount:)
        metadata["water_intake"] += amount.to_i
        save!

        "You have drank #{metadata["water_intake"]} ml of water today."
    end

end