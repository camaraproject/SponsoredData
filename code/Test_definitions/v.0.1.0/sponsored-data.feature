
Feature: Sponsored Data API - Test scenarios (vwip)

  # Version: v0.1.0
  # Sattus: draft

  # Based on the OpenAPI spec sponsored_data.yaml
  # Purpose: validate operations around sponsorship lifecycle, campaign status,
  # callbacks/webhooks and standard error handling across CAMARA/OpenGateway implementations.
  #
  # References: This feature aligns with operations and schemas defined in the OpenAPI doc
  # (paths /sponsorship, /sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status,
  #  /sponsorship/{sponsorId}/{campaignId}/{sessionId}/revoke,
  #  /campaign/{sponsorId}/{campaignId}/campaign-status,
  #  /campaign/{sponsorId}/{campaignId}/active-sponsorships,
  #  /campaign/{sponsorId}/{campaignId}/alert-subscription,
  #  /campaign/management) and components (headers x-correlator, parameters accessToken,
  #  callback header x-callbackToken, schemas PhoneNumber, SponsorId, CampaignId, SessionId,
  #  SponsorshipEndNotification, CampaignNotification, ErrorInfo).
  #
  # Notes:
  # - This feature file assumes a testing framework with step definitions supporting
  #   JSONPath assertions and OAS schema compliance checks (similar to Cucumber tests).
  # - Properties not explicitly overwritten in Scenarios can take any values compliant
  #   with the schemas in the OAS document.

  Background: Common setup for Sponsored Data API
    Given an environment at "apiRoot"
    And the base resource "/sponsored-data/v0.1.0"
    And the header "Content-Type" is set to "application/json"
    And the header "accessToken" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/parameters/x-correlator"

  # --------------------------------------------------------------
  # Success scenarios - start sponsorship
  # --------------------------------------------------------------
  @sponsored_data_startSponsorship_01_generic_success
  Scenario: Start sponsorship session (minimum happy path)
    Given the resource "/sponsorship"
    And the request body is set to a valid object including "sponsorId", "campaignId", "phoneNumber", "webhookUrl", "callbackToken"
    When the request "startSponsorship" is sent as POST
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body contains properties "sponsorId", "campaignId", "sessionId", "startTime", "endTime", "sponsoredDataVolume"

  @sponsored_data_startSponsorship_02_with_explicit_limits
  Scenario: Start sponsorship with explicit dataVolume and duration
    Given the resource "/sponsorship"
    And the request body property "$.dataVolume" is set to a valid integer within [1,1000]
    And the request body property "$.duration" is set to a valid integer within [1,1440]
    And the request body includes valid "sponsorId", "campaignId", "phoneNumber", "webhookUrl", "callbackToken"
    When the request "startSponsorship" is sent as POST
    Then the response status code is 201
    And the response body complies with the OAS schema of the operation response
    And the response property "$.sponsoredDataVolume" is present

  # --------------------------------------------------------------
  # Success scenarios - session status
  # --------------------------------------------------------------
  @sponsored_data_sessionStatus_01_active
  Scenario: Query session status - active
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And valid path parameters for "sponsorId", "campaignId", "sessionId"
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 200
    And the response body complies with the OAS schema of the operation response
    And the response property "$.sessionStatus" is "active"
    And the response property "$.dataVolumeConsumed" is present
    And the response property "$.dataVolumeAvailable" is present

  @sponsored_data_sessionStatus_02_inactive_data_exhausted
  Scenario: Query session status - inactive due to data exhausted
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And valid path parameters for "sponsorId", "campaignId", "sessionId"
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 200
    And the response body complies with the OAS schema of the operation response
    And the response property "$.sessionStatus" is "inactive"
    And the response property "$.endReason" is "data_exhausted"

  # --------------------------------------------------------------
  # Success scenarios - revoke sponsorship
  # --------------------------------------------------------------
  @sponsored_data_revoke_01_successful_revocation
  Scenario: Revoke a sponsorship session
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/revoke"
    And valid path parameters for "sponsorId", "campaignId", "sessionId"
    When the request "revokeSponsorship" is sent as DELETE
    Then the response status code is 200
    And the response body complies with the OAS schema of the operation response
    And the response property "$.requestResult" is "successful_revocation"

  # --------------------------------------------------------------
  # Success scenarios - campaign status
  # --------------------------------------------------------------
  @sponsored_data_campaignStatus_01_active
  Scenario: Query campaign status - active
    Given the resource "/campaign/{sponsorId}/{campaignId}/campaign-status"
    And valid path parameters for "sponsorId", "campaignId"
    When the request "getCampaignStatus" is sent as GET
    Then the response status code is 200
    And the response body complies with the OAS schema of the operation response
    And the response property "$.status" is "active"
    And the response property "$.usedDataVolume" is present
    And the response property "$.completionReason" is "not_available"

  @sponsored_data_campaignStatus_02_completed_time_expired
  Scenario: Query campaign status - completed (time expired)
    Given the resource "/campaign/{sponsorId}/{campaignId}/campaign-status"
    And valid path parameters for "sponsorId", "campaignId"
    When the request "getCampaignStatus" is sent as GET
    Then the response status code is 200
    And the response property "$.status" is "completed"
    And the response property "$.completionReason" is "time_expired"

  @sponsored_data_campaignStatus_03_prepaid_fields_present
  Scenario: Query campaign status - prepaid includes contracted/remaining volumes
    Given the resource "/campaign/{sponsorId}/{campaignId}/campaign-status"
    And valid path parameters for "sponsorId", "campaignId"
    When the request "getCampaignStatus" is sent as GET
    Then the response status code is 200
    And the response property "$.campaignType" is "prepaid"
    And the response property "$.contractedDataVolume" is present
    And the response property "$.remainingDataVolume" is present

  # --------------------------------------------------------------
  # Success scenarios - active sponsorship list
  # --------------------------------------------------------------
  @sponsored_data_activeSponsorships_01_list
  Scenario: Query active sponsorships list for a campaign
    Given the resource "/campaign/{sponsorId}/{campaignId}/active-sponsorships"
    And valid path parameters for "sponsorId", "campaignId"
    When the request "getActiveSponsorships" is sent as GET
    Then the response status code is 200
    And the response body complies with the OAS schema of the operation response
    And the response property "$.activeSponsorships[*].sessionId" is present
    And the response property "$.activeSponsorships[*].phoneNumber" is present
    And the response property "$.totalCount" is present

  # --------------------------------------------------------------
  # Success scenarios - alert subscription and callbacks
  # --------------------------------------------------------------
  @sponsored_data_alertSubscription_01_success
  Scenario: Subscribe to campaign alerts
    Given the resource "/campaign/{sponsorId}/{campaignId}/alert-subscription"
    And valid path parameters for "sponsorId", "campaignId"
    And the request body includes valid "webhookUrl" and "callbackToken"
    And the request body properties "$.alertDataVolumeThresholds", "$.campaignExpiryNotification", "$.dataVolumeExhausted" are set to boolean values
    When the request "configureAlerts" is sent as POST
    Then the response status code is 200
    And the response property "$.requestResult" contains "SUCCESS"

  @sponsored_data_alertSubscription_02_callback_threshold
  Scenario: Receive callback - data volume threshold exceeded (80%)
    Given a prior subscription request where the response was SUCCESS and a valid webhookUrl/callbackToken were provided
    When a campaign notification is sent to the webhookUrl
    Then the API Consumer receives a callback with header "x-callbackToken" matching the subscription "callbackToken"
    And the notification body complies with schema "#/components/schemas/CampaignNotification"
    And the notification property "$.eventType" is "DATA_VOLUME_THRESHOLD_EXCEEDED"
    And the notification property "$.dataContentType" is "application/json"

  @sponsored_data_alertSubscription_03_callback_expired
  Scenario: Receive callback - campaign expired
    Given a prior subscription request where the response was SUCCESS and a valid webhookUrl/callbackToken were provided
    When a campaign notification is sent to the webhookUrl
    Then the API Consumer receives a callback with header "x-callbackToken" matching the subscription "callbackToken"
    And the notification property "$.eventType" is "CAMPAIGN_EXPIRED"

  @sponsored_data_alertSubscription_04_callback_exhausted
  Scenario: Receive callback - campaign data volume exhausted
    Given a prior subscription request where the response was SUCCESS and a valid webhookUrl/callbackToken were provided
    When a campaign notification is sent to the webhookUrl
    Then the API Consumer receives a callback with header "x-callbackToken" matching the subscription "callbackToken"
    And the notification property "$.eventType" is "DATA_VOLUME_EXHAUSTED"

  # --------------------------------------------------------------
  # Success scenarios - sponsorship end callback
  # --------------------------------------------------------------
  @sponsored_data_sponsorshipCallback_01_any_end_state
  Scenario: Receive sponsorship end notification
    Given a prior "startSponsorship" request with a valid webhookUrl/callbackToken
    And a sponsorship session that reaches a final state
    When the Sponsorship server sends a notification to the webhookUrl
    Then the API Consumer receives a callback with header "x-callbackToken" matching the original "callbackToken"
    And the notification body complies with schema "#/components/schemas/SponsorshipEndNotification"
    And the notification property "$.reason" is one of "EXPIRED", "TERMINATED_BY_SPONSOR", "DATA_EXHAUSTED", "USER_DEREGISTERED", "NOT_AVAILABLE"

  # --------------------------------------------------------------
  # Campaign management
  # --------------------------------------------------------------
  @sponsored_data_campaignManagement_01_pause
  Scenario: Pause a campaign
    Given the resource "/campaign/management"
    And the request body includes valid "sponsorId", "campaignId" and "action" set to "pause"
    When the request "manageCampaign" is sent as POST
    Then the response status code is 200
    And the response property "$.status" is "paused"

  @sponsored_data_campaignManagement_02_resume
  Scenario: Resume a campaign
    Given the resource "/campaign/management"
    And the request body includes valid "sponsorId", "campaignId" and "action" set to "resume"
    When the request "manageCampaign" is sent as POST
    Then the response status code is 200
    And the response property "$.status" is one of "resumed", "active"

  @sponsored_data_campaignManagement_03_already_completed
  Scenario: Manage campaign when already completed
    Given the resource "/campaign/management"
    And the request body includes valid identifiers and any action
    And the campaign is already completed
    When the request "manageCampaign" is sent as POST
    Then the response status code is 400

  # --------------------------------------------------------------
  # Error scenarios (generic)
  # --------------------------------------------------------------
  @sponsored_data_generic_400_invalid_argument
  Scenario: Invalid Argument - request body does not comply with schema
    Given the resource "/sponsorship"
    And the request body is set to any value not compliant with the operation schema
    When the request "startSponsorship" is sent as POST
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"

  @sponsored_data_generic_401_unauthenticated
  Scenario: Unauthenticated - missing Authorization
    Given the resource "/sponsorship"
    And the header "accessToken" is removed
    And the request body is set to a valid object
    When the request "startSponsorship" is sent as POST
    Then the response status code is 401
    And the response property "$.code" is one of "UNAUTHENTICATED", "AUTHENTICATION_REQUIRED"

  @sponsored_data_generic_403_permission_denied
  Scenario: Permission denied - token without required scope
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And valid path parameters for "sponsorId", "campaignId", "sessionId"
    And the header "accessToken" is set to a token without required scope or inconsistent context
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 403
    And the response property "$.code" is one of "PERMISSION_DENIED", "INVALID_TOKEN_CONTEXT"

  @sponsored_data_generic_404_not_found
  Scenario: Resource not found
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And path parameters referencing a non-existing resource
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 404
    And the response property "$.code" is "NOT_FOUND"

  @sponsored_data_generic_405_method_not_allowed
  Scenario: Method not allowed on resource
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    When the request is sent with an unsupported HTTP verb
    Then the response status code is 405
    And the response property "$.code" is "METHOD_NOT_ALLOWED"

  @sponsored_data_generic_406_not_acceptable
  Scenario: Not acceptable - invalid Accept header
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And the header "Accept" is set to an unsupported media type
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 406
    And the response property "$.code" is "NOT_ACCEPTABLE"

  @sponsored_data_generic_415_unsupported_media_type
  Scenario: Unsupported media type - invalid Content-Type
    Given the resource "/sponsorship"
    And the header "Content-Type" is set to an unsupported media type
    And the request body is set to any value
    When the request "startSponsorship" is sent as POST
    Then the response status code is 415
    And the response property "$.code" is "UNSUPPORTED_MEDIA_TYPE"

  @sponsored_data_generic_422_unprocessable_entity
  Scenario: Unprocessable entity - device identifiers mismatch or unsupported
    Given the resource "/sponsorship/{sponsorId}/{campaignId}/{sessionId}/session-status"
    And invalid/inconsistent identifiers are provided
    When the request "getSessionStatus" is sent as GET
    Then the response status code is 422
    And the response property "$.code" is one of "DEVICE_IDENTIFIERS_MISMATCH", "DEVICE_NOT_APPLICABLE", "UNSUPPORTED_DEVICE_IDENTIFIERS"

  @sponsored_data_generic_429_rate_limit
  Scenario: Too many requests / quota exceeded
    Given the resource "/sponsorship"
    And the API Consumer has exceeded quota or rate limiting
    When the request "startSponsorship" is sent as POST
    Then the response status code is 429
    And the response property "$.code" is one of "QUOTA_EXCEEDED", "TOO_MANY_REQUESTS"

  @sponsored_data_generic_5xx_server_errors
  Scenario Outline: Server side errors
    Given any resource
    When the request is sent and a server-side condition "<error>" occurs
    Then the response status code is <status>
    And the response property "$.code" is <code>

    Examples:
      | error            | status | code              |
      | internal         | 500    | INTERNAL          |
      | not_implemented  | 501    | NOT_IMPLEMENTED   |
      | bad_gateway      | 502    | BAD_GATEWAY       |
      | unavailable      | 503    | UNAVAILABLE       |
      | timeout          | 504    | TIMEOUT           |

# --------------------------------------------------------------
# Pro Scenarios- Business Conflict & Consistency Scenarios
# --------------------------------------------------------------
  @sponsored_data_pro_start_when_campaign_paused
  Scenario: Start sponsorship when campaign is paused
    Given a campaign with "sponsorId" and "campaignId" that is currently in status "paused"
    And the resource "/sponsorship"
    And the request body includes valid "sponsorId", "campaignId", "phoneNumber", "webhookUrl", "callbackToken"
    When the request "startSponsorship" is sent as POST
    Then the response status code is 409
    And the response property "$.code" is "CONFLICT"

  @sponsored_data_alertSubscription_invalid_webhook
  Scenario: Alert subscription with invalid webhookUrl
    Given the resource "/campaign/{sponsorId}/{campaignId}/alert-subscription"
    And valid path parameters for "sponsorId", "campaignId"
    And the request body property "$.webhookUrl" is set to an invalid URL
    And the request body includes a valid "callbackToken"
    When the request "configureAlerts" is sent as POST
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains "invalid URL"