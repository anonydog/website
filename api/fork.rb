require "aws-sdk-sns"
require "aws-sdk-sts"
require "msgpack"

require "base64"

aws_credentials = Aws::AssumeRoleCredentials.new(
  role_session_name: 'anonydog-website',
  role_arn: ENV['SNS_TOPIC_ROLE_ARN'],
  client: Aws::STS::Client.new(
    region: 'us-west-2',
    credentials: Aws::Credentials.new(
      ENV['SNS_TOPIC_ACCESS_KEY'],
      ENV['SNS_TOPIC_SECRET_KEY'],
    ),
  ),
)
aws_client = Aws::SNS::Client.new(
  region: 'us-west-2',
  credentials: aws_credentials,
)
topic = Aws::SNS::Topic.new(
  ENV['SNS_TOPIC_ARN'],
  client: aws_client,
)

Handler = Proc.new do |req, res|
  params = Hash[URI.decode_www_form(req.body)]
  user = params['user']
  repo = params['repo']

  topic.publish(
    message: Base64.encode64({'user': user, 'repo': repo}.to_msgpack)
  )

  res.status = 302
  res.header['location'] = '/instructions'
end