#!/usr/bin/env python2.7
from __future__ import print_function
import requests
import sys
import os

usage = ("""{argv[0]} ipaddr dnsname

ipaddr: ip address
dnsname: fqdn""".format(argv=sys.argv))


class HoverException(Exception):
    pass

class HoverAPI(object):
    def __init__(self, username, password):
        params = {"username": username, "password": password}
        r = requests.post("https://www.hover.com/api/login", params=params)
        if not r.ok or "hoverauth" not in r.cookies:
            raise HoverException(r)
        self.cookies = {"hoverauth": r.cookies["hoverauth"]}
    def call(self, method, resource, data=None):
        url = "https://www.hover.com/api/{0}".format(resource)
        r = requests.request(method, url, data=data, cookies=self.cookies)
        if not r.ok:
            raise HoverException(r)
        if r.content:
            body = r.json()
            if "succeeded" not in body or body["succeeded"] is not True:
                raise HoverException(body)
            return body

def main(ipaddr, dnsname):
    assert os.environ['HOVER_USERNAME'], os.environ.get('HOVER_USERNAME')
    assert os.environ['HOVER_PASSWORD'], os.environ.get('HOVER_PASSWORD')

    # connect to API
    client = HoverAPI(os.environ['HOVER_USERNAME'],
                      os.environ['HOVER_PASSWORD'])

    # get all DNS records
    print('fetching hover-api dns records: ', end='')
    sys.stdout.flush()
    result = client.call("get", "dns")
    assert result['succeeded'], result

    # transpose cmd-line arguments to {a record}{domain name}
    tgt_dnsname, _part_domain, _part_tld = dnsname.rsplit('.', 3)
    tgt_domainname = '.'.join((_part_domain, _part_tld))

    # discover existing ``result_dnsrecord``, if any
    matching_dns_record = None
    matching_domain_record = None
    for result_domainname in result['domains']:
        if result_domainname['domain_name'] == tgt_domainname:
            matching_domain_record = result_domainname
            for dns_entry in result_domainname['entries']:
                if dns_entry['name'] == tgt_dnsname:
                    matching_dns_record = dns_entry
                    break
        if matching_dns_record is not None and matching_domain_record is not None:
            print('(match) ', end='')
            sys.stdout.flush()
            break
    print("OK")

    # expire previous ``dns_record``, if any
    if matching_domain_record is None:
        print("First record for domain {0}, no previous record exists."
                .format(tgt_domainname))
    elif matching_dns_record is None:
        print("First record for dnsname {0}.{1}, no previous record exists."
                .format(tgt_dnsname, tgt_domainname))
    else:
        print("deleting existing dns record: {0}.{1} ... "
              .format(tgt_dnsname, tgt_domainname), end="")
        sys.stdout.flush()
        result = client.call("delete", "dns/{0}".format(matching_dns_record['id']))
        assert result['succeeded'], result
        print("OK")

    print("creating A record {0}.{1} => {2} ... "
            .format(tgt_dnsname, tgt_domainname, ipaddr), end="")
    sys.stdout.flush()

    ## create a new A record:
    record = {"name": tgt_dnsname, "type": "A", "content": ipaddr}
    post_id = "domains/{0}/dns".format(matching_domain_record['id'])
    result = client.call("post", post_id, record)
    assert result['succeeded'], result
    print("OK")

    return 0

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('main() takes exactly 2 arguments ({0} given)'
                .format(len(sys.argv) - 1), file=sys.stderr)
        print(usage, file=sys.stderr)
        exit(1)

    if set(['-h', '--help']) & set(sys.argv[1:]):
        print(usage)
        exit(0)

    exit(main(*sys.argv[1:3]))
