{
    "target": {
        "scope": {
            "advanced_mode": true,
            "exclude": [],
            "include": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.corda\\.net$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.corda\\.net$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.r3\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.r3\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ]
        }
    }
}
