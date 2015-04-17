import urllib2

def public_ip():
    return {
        'public_ip': urllib2.urlopen("http://instance-data/latest/meta-data/public-ipv4").read()
    }
