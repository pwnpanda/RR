rget": {
        "scope": {
            "advanced_mode": true,
            "exclude": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^spotify\\.com,.*\\.spotify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^spotify\\.com,.*\\.spotify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^investors\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^investors\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^shopify\\.asia$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^shopify\\.asia$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^go\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^go\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.email\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.email\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^hackerone\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
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
                    "host": "^.*\\.shopify\\.io$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.io$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^cdn\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^cdn\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^livechat\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^livechat\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^community\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^community\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partner-training\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partner-training\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ],
            "include": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.myshopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.myshopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^accounts\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^accounts\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopifykloud\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopifykloud\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^exchangemarketplace\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^exchangemarketplace\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ]
        }
    }
}{
    "target": {
        "scope": {
            "advanced_mode": true,
            "exclude": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^spotify\\.com,.*\\.spotify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^spotify\\.com,.*\\.spotify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^investors\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^investors\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^shopify\\.asia$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^shopify\\.asia$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^go\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^go\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.email\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.email\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^hackerone\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
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
                    "host": "^.*\\.shopify\\.io$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.io$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^cdn\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^cdn\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^livechat\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^livechat\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^community\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^community\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partner-training\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partner-training\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ],
            "include": [
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.myshopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^your-store\\.myshopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^partners\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^accounts\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^accounts\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopifykloud\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopifykloud\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^.*\\.shopify\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^exchangemarketplace\\.com$",
                    "port": "^80$",
                    "protocol": "http"
                },
                {
                    "enabled": true,
                    "file": "^/.*",
                    "host": "^exchangemarketplace\\.com$",
                    "port": "^443$",
                    "protocol": "https"
                }
            ]
        }
    }
}
