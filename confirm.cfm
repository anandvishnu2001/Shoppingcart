<cfset control = CreateObject("component", "components.control")>
<cfif structKeyExists(session, 'user') 
    AND session.user.access>
    <cfif NOT structKeyExists(url, 'order')>
        <cflocation url="index.cfm" addToken="no">
    </cfif>
<cfelse>
    <cflocation url="login.cfm" addToken="no">
</cfif>
<cfset control.paymentMail(order=url.order)>
<html lang="en">
	<head>
		<link href="/css/admin.css" rel="stylesheet">
		<link href="/css/bootstrap.min.css" rel="stylesheet">
	</head>
	<body class="container-fluid p-0 d-flex flex-column align-items-center">
		<nav id="main-nav" class="container-fluid navbar navbar-expand-lg justify-content-center bg-primary gap-5 z-3 fw-bold fixed-top" data-bs-theme="dark">
            <a class="flex-grow-1 navbar-brand ms-2" href="index.cfm">
                <img src="/images/shop.png" width="40" height="40" class="img-fluid">
                ShopKart
            </a>
		</nav>
        <div class="container-fluid h-100 d-flex flex-row justify-content-center align-items-center gap-5 p-5 mt-5">
            <div class="card d-grid bg-light col-6 p-3 gap-5 p-5">
                <h2 class="alert alert-success fw-bold">
                    <img src="/images/success.png" width="100" height="100" class="img-fluid">
                    Payment Successful!!!
                </h2>
                <a class="btn btn-outline-dark fw-bold" <cfoutput>href="user.cfm?keyword=#url.order#"</cfoutput>>Order Details</a>
                <a class="btn btn-outline-primary fw-bold" href="index.cfm">Continue Exploring</a>
            </div>
        </div>
		<script type="text/javascript" src="/js/jQuery.js"></script>
		<script type="text/javascript" src="/js/home.js"></script>
		<script type="text/javascript" src="/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="/js/bootstrap.bundle.min.js"></script>
	</body>
</html>