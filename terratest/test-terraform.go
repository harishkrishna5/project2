package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/gruntwork-io/terratest/modules/random"
  "github.com/stretchr/testify/assert"
)

func TestTerraformS3Bucket(t *testing.T) {
  t.Parallel()

  // Define a unique name for the bucket (to avoid conflicts)
  uniqueID := random.UniqueId()
  bucketName := "my-test-bucket-" + uniqueID

  // Set up the Terraform options
  options := &terraform.Options{
    TerraformDir: "../", // Directory containing your Terraform code
    Vars: map[string]interface{}{
      "bucket_name": bucketName,
    },
    NoColor: true,
  }

  // Initialize and apply Terraform code
  terraform.InitAndApply(t, options)

  // Output the name of the bucket
  bucketNameOutput := terraform.Output(t, options, "bucket_name")

  // Assert that the bucket name matches the expected name
  assert.Equal(t, bucketName, bucketNameOutput)

  // Clean up resources after the test is complete
  defer terraform.Destroy(t, options)
}
