---
layout: page
permalink: /merchandise/
title: Merchandise
weight: 100
menufontawesome: fal fa-tshirt
---

<div id="shop"><i class="fad fa-spinner"></i> Spreadshop loading...</div>

<script>
    var spread_shop_config = {
        shopName: 'chizography',
        prefix: 'https://shop.spreadshirt.co.uk',
        baseId: 'shop',
        locale: 'EN_GB',
        startToken: 'secret+cthulhu?collection=sqdOueCgzN',
    };
</script>

<!-- pull in the spreadshirt magic -->
<script type="text/javascript" src="https://shop.spreadshirt.net/js/shopclient.nocache.js"></script>

<!-- load CSS *after* the JS does its thing -->
<link rel="stylesheet" href="/assets/spreadshirt.css">
