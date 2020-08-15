{
    "target": {
        "scope": {
            "advanced_mode": true,
            "exclude": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^track\\.api\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^track\\.api\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^support\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^support\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.vendecommerce\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.vendecommerce\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partnerportal\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partnerportal\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ],
            "include": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^secure\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^secure\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^developers\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^developers\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.vendhq\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^www\\.vendhq\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ]
        }
    }
}
