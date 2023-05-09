resource "godaddy_domain_record" "gpterror" {
  domain = "gpterror.online"

  record {
    name = "@"
    type = "A"
    data = "15.197.142.173"
    ttl = 600
  }

  record {
    name = "@"
    type = "A"
    data = "3.33.152.147"
    ttl = 600
  }

  record {
    name = "www"
    type = "CNAME"
    data = aws_cloudfront_distribution.this.domain_name
    ttl = 3600
  }

  record {
    name = "_domainconnect"
    type = "CNAME"
    data = "_domainconnect.gd.domaincontrol.com"
    ttl = 3600
  }
}
