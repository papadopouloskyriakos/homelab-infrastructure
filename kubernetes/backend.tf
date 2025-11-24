terraform {
  backend "http" {
    # Backend config will be provided via environment variables:
    # TF_HTTP_ADDRESS, TF_HTTP_LOCK_ADDRESS, TF_HTTP_UNLOCK_ADDRESS
    # TF_HTTP_USERNAME, TF_HTTP_PASSWORD
    # TF_HTTP_LOCK_METHOD, TF_HTTP_UNLOCK_METHOD
  }
}
