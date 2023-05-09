# GPTerror
www.gpterror.online is a one page site that provides a random horror story writen by a GPT OpenAI Model.

## How it works
Each request to the OpenAi API take more than 30 seconds, so to make the response time viable, this app has the following structure:
- A S3 to storage files containing the stories.
- An Auto Scale Group who provides a EC2 every time the S3 file number is less then the minimun threshould.
  - The EC2 provided make requests to the OpenAI API, generating and uploading new files to the S3.
- A Lambda responsible for serving the first file stored on the S3. Each file served is deleted during the request.
