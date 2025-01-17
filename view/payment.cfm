<cfif structKeyExists(form, 'okbtn')>
    <cfset variables.shipping = {
        'name' = form.name,
        'phone' = form.phone,
        'house' = form.house,
        'street' = form.street,
        'city' = form.city,
        'state' = form.state,
        'country' = form.country,
        'pincode' = form.pincode,
        'user' = session.user.user
    }>
    <cfset variables.error = application.control.modifyShipping(data=variables.shipping)>
    <cfif arrayLen(variables.error) NEQ 0>
        <nav class="alert alert-danger alert-dismissible fade show text-center mt-5 z-3 fw-bold">
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            <cfoutput>
                #arrayToList(variables.error)#
            </cfoutput>
        </nav>
    </cfif>
<cfelseif structKeyExists(form, 'paybtn')>
    <cfset variables.order = {
        'cardname' = form.cardname,
        'cardno' = form.cardno,
        'expiry' = form.expiry,
        'cvv' = form.cvv,
        'id' = form.shippingId,
        'idType' = form.idType,
        'address' = form.shippingAddress,
        'user' = session.user.user
    }>
    <cfset variables.output = application.control.payOrder(variables.order)>
    <cfdump  var="#variables.output#">
    <cfif arrayLen(variables.output.error) EQ 0 AND structKeyExists(variables.output, 'order')>
        <cflocation  url="/confirm.cfm?order=#variables.output.order#" addToken="no">
    <cfelse>
        <div class="alert alert-danger alert-dismissible fade show text-center mt-5 z-3 fw-bold">
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            Payment Failed!!! Due to:
            <cfoutput>
                #arrayToList(variables.output.error)#
            </cfoutput>
        </div>
    </cfif>
</cfif>
<html lang="en">
	<head>
		<link href="/css/admin.css" rel="stylesheet">
		<link href="/css/bootstrap.min.css" rel="stylesheet">
	</head>
	<body class="container-fluid p-0 d-flex flex-column align-items-center">
		<nav id="main-nav" class="container-fluid navbar navbar-expand-lg justify-content-between bg-primary gap-5 z-1 fw-bold fixed-top" data-bs-theme="dark">
            <a class="navbar-brand ms-2" href="/home">
                <img src="/images/shop.png" width="40" height="40" class="img-fluid">
                ShopKart
            </a>
		</nav>
        <div class="container-fluid h-100 d-flex flex-row justify-content-evenly align-items-start z-0 gap-5 p-5 mt-5">
            <div class="col-7 h-100 overflow-y-scroll d-flex flex-column gap-5 p-5">
                <div class="card h-75 bg-light p-3">
                    <h2 class="card-header fw-bold text-primary">Shipping Address</h2>
                    <ul class="card-body overflow-y-scroll list-group d-flex flex-column p-1 gap-3">
                        <cfset variables.addresses = application.control.getShipping(user=session.user.user)>
                        <cfif arrayLen(variables.addresses) GT 0>
                            <cfloop array="#variables.addresses#" item="address">
                                <cfoutput>
                                    <div class="card fw-bold list-group-item">
                                        <div class="d-flex align-items-center form-check gap-3">
                                            <input type="radio" class="form-check-input bg-dark" id="address#address.id#" name="address" value="#address.id#">
                                            <label class="form-check-label" for="address#address.id#">
                                                <div>
                                                    <p class="card-title">#address.name# #address.phone#</p>
                                                    <p class="card-text">
                                                        #address.house#, #address.street#, #address.city#,
                                                        #address.state#, #address.country#, PIN-#address.pincode#
                                                    </p>
                                                </div>
                                            </label>
                                        </div>
                                    </div>
                                </cfoutput>
                            </cfloop>
                        <cfelse>
                            <h1 class="text-center text-warning">Address is Empty!!</h1>
                        </cfif>
                    </ul>
                    <button class="card-footer btn fw-bold btn-primary btn-block" data-bs-toggle="modal" data-bs-target="#modal"
                        data-bs-action="add">
                            <span class="h3">Add Address</span>
                    </button>
                </div>
                <div class="card h-75 bg-light fw-bold p-3">
                    <h2 class="card-header fw-bold text-primary">Order Details</h2>
                    <cfset variables.carter = application.control.getCart(session.user.user)>
                    <cfset variables.orderTotal = 0>
                    <cfset variables.orderTax = 0>
                    <cfif structKeyExists(url, 'pro')>
                        <cfset variables.orderItem = application.control.getProduct(product=url.pro)>
                        <cfoutput>
                            <div class="card-body d-flex flex-row flex-wrap justify-content-evenly">
                                <div id="productpic#variables.orderItem[1].id#" class="card-img w-25 carousel slide" data-bs-ride="carousel" data-bs-theme="dark">
                                    <div class="carousel-inner">
                                        <cfloop array="#variables.orderItem[1].images#" index="index" item="image">
                                            <div class="carousel-item <cfif index EQ 1> active</cfif>">
                                                <img src="/uploads/#image.image#" alt="Product image" class="d-block w-100">
                                            </div>
                                        </cfloop>
                                    </div>
                                    <button class="carousel-control-prev" type="button" data-bs-target="#chr(35)#productpic#variables.orderItem[1].id#" data-bs-slide="prev">
                                        <span class="carousel-control-prev-icon"></span>
                                    </button>
                                    <button class="carousel-control-next" type="button" data-bs-target="#chr(35)#productpic#variables.orderItem[1].id#" data-bs-slide="next">
                                        <span class="carousel-control-next-icon"></span>
                                    </button>
                                </div>
                                <div class="col-5 d-flex flex-column justify-content-evenly fw-bold">
                                    <p class="card-title text-primary">#variables.orderItem[1].name#</p>
                                    <cfset variables.orderTotal += variables.orderItem[1].price+(variables.orderItem[1].price*variables.orderItem[1].tax/100)>
                                    <cfset variables.orderTax += variables.orderItem[1].price*variables.orderItem[1].tax/100>
                                    <div class="d-grid fw-bold">
                                        <p class="card-text text-danger">#numberFormat(variables.orderItem[1].price)#</p>
                                        <p class="card-text text-info">#variables.orderItem[1].tax#%</p>
                                    </div>
                                </div>
                                <div class="col-5 fw-bold">
                                    <p class="card-text text-danger">Total Price: #numberFormat(variables.orderItem[1].price+(variables.orderItem[1].price*variables.orderItem[1].tax/100))#</p>
                                    <p class="card-text text-info">Tax: #numberFormat(variables.orderItem[1].price*variables.orderItem[1].tax/100)#</p>
                                </div>
                            </div>
                        </cfoutput>
                    <cfelseif structKeyExists(variables, 'carter') AND arrayLen(variables.carter.items) GT 0>
                        <ul class="card-body overflow-y-scroll list-group d-flex flex-column p-1">
                            <cfset variables.orderTotal = variables.carter.totalprice>
                            <cfset variables.orderTax = variables.carter.totaltax>
                            <cfloop array="#variables.carter.items#" item="item">
                                    <li class="list-group-item d-flex flex-row flex-wrap justify-content-evenly gap-1">
                                        <cfoutput>
                                                <div id="productpic#item.product#" class="card-img w-25 carousel slide" data-bs-ride="carousel" data-bs-theme="dark">
                                                    <div class="carousel-inner">
                                                        <cfloop array="#item.images#" index="index" item="image">
                                                            <div class="carousel-item <cfif index EQ 1> active</cfif>">
                                                                <img src="/uploads/#image.image#" alt="Product image" class="d-block w-100">
                                                            </div>
                                                        </cfloop>
                                                    </div>
                                                    <button class="carousel-control-prev" type="button" data-bs-target="#chr(35)#productpic#item.product#" data-bs-slide="prev">
                                                        <span class="carousel-control-prev-icon"></span>
                                                    </button>
                                                    <button class="carousel-control-next" type="button" data-bs-target="#chr(35)#productpic#item.product#" data-bs-slide="next">
                                                        <span class="carousel-control-next-icon"></span>
                                                    </button>
                                                </div>
                                                <div class="col-5 d-flex flex-column justify-content-evenly fw-bold">
                                                    <p class="card-title text-primary">#item.name#</p>
                                                    <div class="d-grid fw-bold">
                                                        <p class="card-text text-danger">Unit Price: #numberFormat(item.price)#</p>
                                                        <p class="card-text text-info">Tax Rate: #item.tax#%</p>
                                                        <p class="card-text text-muted">Quantity: #item.quantity#</p>
                                                    </div>
                                                </div>
                                                <div class="col-5 fw-bold">
                                                    <p class="card-text text-danger">Total Price: #numberFormat(item.totalprice)#</p>
                                                    <p class="card-text text-info">Tax: #numberFormat(item.totaltax)#</p>
                                                </div>
                                        </cfoutput>
                                    </li>
                            </cfloop>
                        </ul>
                    <cfelse>
                        <h1 class="bg-warning shadow text-center text-dark">Order Item not Selected!!</h1>
                    </cfif>
                </div>
            </div>
            <div class="card bg-light fw-bold col-4 p-3 gap-5 p-5">
                <p class="card-text bg-info text-center text-danger">
                    Total Payable Amount : <cfoutput>#numberFormat(variables.orderTotal)#</cfoutput><br>
                    Total Estimated Tax : <cfoutput>#numberFormat(variables.orderTax)#</cfoutput>
                </p>
                <button id="paymentbtn" class="btn btn-success"
                    data-bs-target="#modal" data-bs-toggle="modal" data-bs-action="pay"
                    <cfoutput>
                        <cfif structKeyExists(url, 'pro')>
                            data-bs-id="#url.pro#" data-bs-idtype="product"
                        <cfelseif arrayLen(variables.carter.items) GT 0>
                            data-bs-id="#variables.carter.items[1].id#" data-bs-idtype="cart"
                        </cfif>
                    </cfoutput>>
                    Payment
                </button>
                <a class="btn btn-danger" href="/cart">Cancel</a>
            </div>
        </div>
        <div class="modal fade" id="modal" data-bs-theme="dark">
            <div class="modal-dialog">
                <div class="modal-content d-flex p-3">
                    <div class="modal-header d-flex">
                        <h2 id="modalhead" class="modal-title flex-grow-1 fw-bold text-primary text-center">Shipping Address Details</h2>
                        <button type="button" class="btn-close border rounded" data-bs-dismiss="modal"></button>
                    </div>
                    <form id="addressForm" name="addressForm" class="modal-body d-flex flex-column gap-2 p-3" action="" method="post" enctype="multipart/form-data">
                        <fieldset id="modify-mode" class="d-flex flex-column rounded border gap-2 p-3">
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="name" name="name" placeholder="">
                                <label for="name" class="form-label text-light">Name</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="phone" name="phone" placeholder="">
                                <label for="phone" class="form-label text-light">Phone</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="house" name="house" placeholder="">
                                <label for="house" class="form-label text-light">House/Flat</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="street" name="street" placeholder="">
                                <label for="street" class="form-label text-light">Street</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="city" name="city" placeholder="">
                                <label for="city" class="form-label text-light">City</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="state" name="state" placeholder="">
                                <label for="state" class="form-label text-light">State</label>
                            </div>
                            <div class="form-floating">
                                <input class="form-control text-warning" type="text" id="country" name="country" placeholder="">
                                <label for="country" class="form-label text-light">Country</label>
                            </div>
                            <div class="">
                                <input class="form-control text-warning" type="text" id="pincode" name="pincode" placeholder="">
                                <label for="pincode" class="form-label text-light">Pincode</label>
                            </div>
                        </fieldset>
                        <fieldset id="pay-mode" class="d-flex flex-wrap justify-content-evenly rounded border gap-2 p-3">
                            <div class="col-12">
                                <label for="cardNumber" class="form-label text-light">Card Number</label>
                                <input type="text" class="form-control text-warning" id="cardno" name="cardno" placeholder="1234 5678 9012 3456" autocomplete="off">
                            </div>
                            <div class="col-5">
                                <label for="expiryDate" class="form-label text-light">Expiry Date</label>
                                <input type="text" class="form-control text-warning" id="expiry" name="expiry" placeholder="MM/YY" autocomplete="off">
                            </div>
                            <div class="col-5">
                                <label for="cvv" class="form-label text-light">CVV</label>
                                <input type="text" class="form-control text-warning" id="cvv" name="cvv" placeholder="123" autocomplete="off">
                            </div>
                            <div class="col-12">
                                <label for="cardholderName" class="form-label text-light">Cardholder Name</label>
                                <input type="text" class="form-control text-warning" id="cardname" name="cardname" placeholder="John Doe" autocomplete="off">
                            </div>
                        </fieldset>
                        <input type="hidden" name="shippingId" id="shippingId">
                        <input type="hidden" name="shippingAddress" id="shippingAddress">
                        <input type="hidden" name="idType" id="idType">
                    </form>
                    <div class="modal-footer d-flex justify-content-between">
                        <button name="okbtn" id="okbtn" type="submit" class="btn btn-outline-success fw-bold" form="addressForm"></button>
                        <button name="paybtn" id="paybtn" type="submit" class="btn btn-outline-success fw-bold" form="addressForm">Pay</button>
                        <button type="button" class="btn btn-outline-danger fw-bold" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
		<script type="text/javascript" src="/js/jQuery.js"></script>
		<script type="text/javascript" src="/js/home.js"></script>
		<script type="text/javascript" src="/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="/js/bootstrap.bundle.min.js"></script>
	</body>
</html>