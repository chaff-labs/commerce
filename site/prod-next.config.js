module.exports = {
  "commerce": {
    "provider": "shopify",
    "features": {
      "cart": true,
      "search": true,
      "wishlist": false,
      "customerAuth": true,
      "customCheckout": false
    }
  },
  "i18n": {
    "locales": [
      "en-US",
      "es"
    ],
    "defaultLocale": "en-US"
  },
  "experimental": {
    "esmExternals": "loose"
  },
  "output": "standalone",
  "images": {
    "domains": [
      "store.chaff.labs",
      "cdn.shopify.com"
    ]
  },
  "env": {
    "COMMERCE_CART_ENABLED": true,
    "COMMERCE_SEARCH_ENABLED": true,
    "COMMERCE_CUSTOMERAUTH_ENABLED": true
  }
}