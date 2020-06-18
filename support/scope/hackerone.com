{
    "target": {
        "scope": {
            "advanced_mode": true,
            "exclude": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^support\\.hackerone\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^go\\.hacker\\.one$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^//.*",
                    "host": "^www\\.hackeronestatus\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^//.*",
                    "host": "^info\\.hacker\\.one$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^ma\\.hacker\\.one$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ],
            "include": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^hackerone\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^api\\.hackerone\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^//.*",
                    "host": "^hackerone-us-west-2-production-attachments\\.s3-us-west-2\\.amazonaws\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.vpn\\.hackerone\\.net$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.vpn\\.hackerone\\.net$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.hackerone\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^errors\\.hackerone\\.net$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.hackerone-ext-content\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^//.*",
                    "host": "^.*\\.hackerone-user-content\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^ctf\\.hacker101\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ]
        }
    }
}
