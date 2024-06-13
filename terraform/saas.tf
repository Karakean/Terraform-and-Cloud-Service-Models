# 3. SaaS

resource "aws_lex_slot_type" "demo_lex_slot_type" {
  name        = "CustomTopicTypes"
  description = "Custom slot type for topics of exam questions"

  enumeration_value {
    value = "Docker Swarm"
  }

  enumeration_value {
    value = "OpenStack"
  }

  enumeration_value {
    value = "Kubernetes"
  }
}

resource "aws_lex_intent" "demo_lex_intent" {
  depends_on = [aws_lex_slot_type.demo_lex_slot_type]

  confirmation_prompt {
    max_attempts = 2

    message {
      content      = "Would you like to proceed with receiving the exam questions for the Management of Cloud Environments course?"
      content_type = "PlainText"
    }
  }

  create_version = false
  name           = "ZSCH_intent"
  description    = "Intent to provide exam questions for the Management of Cloud Environments course"

  fulfillment_activity {
    type = "ReturnIntent"
  }

  rejection_statement {
    message {
      content      = "Okay, I will not provide the exam questions."
      content_type = "PlainText"
    }
  }

  sample_utterances = [
    "I would like to receive exam questions",
    "Give me exam questions for the Management of Cloud Environments course",
  ]

  slot {
    description = "The topic of the exam questions"
    name        = "Topic"
    priority    = 1

    sample_utterances = [
      "I need exam questions on {Topic}",
    ]

    slot_constraint   = "Required"
    slot_type         = aws_lex_slot_type.demo_lex_slot_type.name
    slot_type_version = "$LATEST"

    value_elicitation_prompt {
      max_attempts = 2

      message {
        content      = "What topic would you like the exam questions to cover?"
        content_type = "PlainText"
      }
    }
  }

  slot {
    description = "The number of exam questions"
    name        = "NumberOfQuestions"
    priority    = 2

    sample_utterances = [
      "I need {NumberOfQuestions} exam questions",
    ]

    slot_constraint   = "Required"
    slot_type         = "AMAZON.NUMBER"

    value_elicitation_prompt {
      max_attempts = 2

      message {
        content      = "How many exam questions do you need?"
        content_type = "PlainText"
      }
    }
  }
}

resource "aws_lex_bot" "demo_lex_bot" {
  depends_on = [aws_lex_intent.demo_lex_intent]

  abort_statement {
    message {
      content      = "Sorry, I am not able to assist at this time"
      content_type = "PlainText"
    }
  }

  child_directed = false

  clarification_prompt {
    max_attempts = 2

    message {
      content      = "I didn't understand you, what would you like to do?"
      content_type = "PlainText"
    }
  }

  create_version              = false
  description                 = "A bot that gives exam questions for the Management of Cloud Environments course."
  idle_session_ttl_in_seconds = 600

  intent {
    intent_name    = aws_lex_intent.demo_lex_intent.name
    intent_version = "$LATEST"
  }

  locale           = "en-US"
  name             = "ZSCH"
  process_behavior = "BUILD"
  voice_id         = "Salli"
}
