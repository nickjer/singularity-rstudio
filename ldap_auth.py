#!/usr/bin/env python3

"""Verify a username and password combination using LDAP

Reads a password from stdin, or prompts for a password if none is
provided.

Example usage:

    % export LDAP_CERT_FILE=/path/to/trusted_root_cert.pem  # optional, see [0]
    % export LDAP_HOST=some.ldap.server.org
    % export LDAP_USER_DN='CN=%s,CN=Users,DC=MyDomain,DC=com'
    % ldap_auth.py username && echo ok || echo failed
    Password:  # enter correct password
    Success
    ok
    % ldap_auth.py username && echo ok || echo failed
    Password:  # enter incorrect password
    LDAPInvalidCredentialsResult - 49 - invalidCredentials - None - 80090308: LdapErr: DSID-0C09042F, comment: AcceptSecurityContext error, data 52e, v2580 - bindResponse - None
    failed

[0] A certificate file is only required if the default system
certificate store is not accepted by the LDAP server.

"""

import os
import sys
import argparse
import ssl
import getpass

import ldap3
from ldap3.core.exceptions import LDAPInvalidCredentialsResult

getenv = os.environ.get


def main(arguments):

    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('user')
    parser.add_argument(
        '--cert-file', default=getenv('LDAP_CERT_FILE'),
        help="""Path to TLS certificate used for encrypting the
        connection to the LDAP server. Uses value of LDAP_CERT_FILE if
        defined.""")
    parser.add_argument(
        '--host', default=getenv('LDAP_HOST'),
        help="""Name of the LDAP host. Uses value of LDAP_HOST
        by default."""
    )
    parser.add_argument(
        '--user-dn', default=getenv('LDAP_USER_DN'),
        help="""Base DN for user search in LDAP directory, including a
        placeholder for USER (will look something like
        "CN=%%s,CN=Users,DC=MyDomain,DC=com"). Uses value of
        LDAP_USER_DN by default."""
    )
    parser.add_argument(
        '--timeout', type=int, default=3,
        help='Timeout for LDAP server connection in seconds [%(default)s].')

    args = parser.parse_args(arguments)

    if not sys.stdin.isatty():  # stdin has content
        password = sys.stdin.read().strip()
    else:
        password = getpass.getpass()

    conn = ldap3.Connection(
        ldap3.Server(
            args.host,
            port=636,
            use_ssl=True,
            tls=ldap3.Tls(
                ca_certs_file=args.cert_file,
                # validate=ssl.CERT_NONE,
                validate=ssl.CERT_REQUIRED,
            ),
            get_info=ldap3.NONE,
            connect_timeout=args.timeout,
        ),
        auto_bind=False,
        client_strategy=ldap3.SYNC,
        user=args.user_dn % args.user,
        password=password,
        raise_exceptions=True,
        check_names=True)

    conn.start_tls()

    try:
        conn.bind()
    except LDAPInvalidCredentialsResult as err:
        print(err)
        status = 1
    else:
        print('Success')
        status = 0
    finally:
        conn.unbind()
        sys.exit(status)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
