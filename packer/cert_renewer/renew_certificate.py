import boto3, os, time, OpenSSL
from datetime import datetime, date

def get_acm_cert(domain_name):
  values = acm.list_certificates()['CertificateSummaryList']
  try:
    for value in values:
      if value['DomainName'] == domain_name:
        cert = value
    return {'certificate': acm.get_certificate(CertificateArn=cert['CertificateArn'])['Certificate'], 'arn': cert['CertificateArn']}
  except:
    return {}

def time_left_for_expiration(acm_cert):
  expiration_date = OpenSSL.crypto \
    .load_certificate(OpenSSL.crypto.FILETYPE_PEM, acm_cert) \
    .get_notAfter().decode('utf-8')
  return (datetime.strptime(expiration_date, '%Y%m%d%H%M%S%z').date() - date.today()).days

def create_or_renew(arn=None):
  if arn:
    os.system('sh /tmp/renew_with_certbot.sh {}'.format(arn))
    return acm.import_certificate(Certificate=open(files_path.format('cert.pem')).read(), \
      PrivateKey=open(files_path.format('privkey.pem'), "rb").read(), \
      CertificateChain=open(files_path.format('chain.pem'), "rb").read(), \
      CertificateArn=arn)
  else:
    # this does not work. If the code reach this condition means that the ACM cert
    # does not exist. If the cert does not exist, the CF distribution is not working :(
    os.system('sh /tmp/renew_with_certbot.sh')
    return acm.import_certificate(Certificate=open(files_path.format('cert.pem')).read(), \
      PrivateKey=open(files_path.format('privkey.pem'), "rb").read(), \
      CertificateChain=open(files_path.format('chain.pem'), "rb").read())

def upload_key_to_s3():
  boto3.client('s3').put_object(Bucket='rebelatto', \
  Key='certs/gpterror/www/private_key{}.pem'.format(time.time()), \
  Body=open(files_path.format('privkey.pem')).read())

def call():
  acm_object = get_acm_cert('www.gpterror.online')
  if acm_object:
    time_left = time_left_for_expiration(acm_object['certificate'])
    if time_left < 10:
      create_or_renew(acm_object['arn'])
      upload_key_to_s3()
      print('certificate renewed')
    else:
      print("no renewal needed")
  else:
    create_or_renew()
    upload_key_to_s3()
    print('new certificate issued')

files_path='/etc/letsencrypt/live/www.gpterror.online/{}'
acm = boto3.client('acm', region_name='us-east-1')
call()
