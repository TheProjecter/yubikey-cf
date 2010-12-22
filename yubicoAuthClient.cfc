<!---
	Page: 		yubicoAuthClient.cfc
	Author:		rdudley robert@xset.co.uk
	Created:	12/22/2010
	
	Version:	0.0.2
	Updated:	12/22/2010
	
	Description:
	YubiKey Web Services API Client
	
	TODO:
	
	* Add HMAC-SHA-1 support for signing
	* Add nonce to request
	* Add additional request fields
		timestamp
		sl
		timeout
	* Test against 3rd party API servers
	
	Copyright (c) 2010 Robert Dudley

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
	
--->
<cfcomponent hint="handles yubico authentication" output="false">
	<cfproperty name="yubiCoURL" hint="the URL to use for authentication" type="string" default="http://api.yubico.com/wsapi/" />
	<cfproperty name="clientId" displayname="the YubiCo Client ID to pass to the web service" hint="the YubiCo Client ID to pass to the web service" type="numeric" default="16" />

	<cffunction name="getYubiCoURL" access="package" output="false" returntype="string">
		<cfreturn yubiCoURL>
		
	</cffunction>

	<cffunction name="setYubiCoURL" access="private" output="false" returntype="void">
		<cfargument name="argYubiCoURL" type="string">
		<cfset yubiCoURL=argYubiCoURL/>
		
	</cffunction>

	<cffunction name="getClientId" access="package" output="false" returntype="numeric">
		<cfreturn clientId>
		
	</cffunction>

	<cffunction name="setClientId" access="private" output="false" returntype="void">
		<cfargument name="argClientId" type="numeric">
		<cfset clientId=argClientId/>
		
	</cffunction>

	<cffunction name="authenticate" hint="authenticates an OTP against the YubiCo Web Service" access="public" output="false" returntype="struct">
		<cfargument name="otp" type="string" hint="the OTP to authenticate" required="true" />
		
		<cfset var local = structNew() />
		
		<cfset local.authResult = structNew() />
		
		<cfset local.authUrl = "#getYubiCoURL()#verify?id=#getClientId()#&otp=#arguments.otp#" />
		
		<cfset local.authResult.authUrl = local.authUrl />
					
		<cfhttp method="get" result="local.authResponse" url="#local.authUrl#" throwonerror="true" />
		
		<cfif structKeyExists(local.authResponse,"FileContent")>
				
			<cfset structAppend(local.authResult, parseAuthResponse(local.authResponse.filecontent),false) />
		
		</cfif>
		
		<cfreturn local.authResult /> 
		
	</cffunction>
	
	<cffunction name="parseAuthResponse" output="false" access="private" returntype="struct" hint="parses out the response from YubiKey API and returns a struct of values">
	
		<cfargument name="authResponse" type="string" required="true"/>
		
		<cfset var local = structNew() />
		
		<cfset local.authResponseStruct = structNew() />
			
		<cfset local.authResponse = reReplace(arguments.authResponse,"\s",",", "all") />
		
		<cfset local.aryAuthResp = listToArray(local.authResponse) />
			
		<cfloop array="#local.aryAuthResp#" index="local.i">
		
			<cfset local.j = replace(local.i,"=","~","one") />
			
			<cfset local.tmpKey = listFirst(local.j,"~") />
			<cfset local.tmpVal = listLast(local.j,"~") />
			
			<cfset structInsert(local.authResponseStruct,local.tmpKey,local.tmpVal) />
					
		</cfloop>
			
		<cfreturn local.authResponseStruct />
	
	</cffunction>

	<cffunction name="init" hint="constructor" access="public" returntype="yubicoAuthClient">
		
		<cfargument name="yubiCoURL" type="string" hint="the URL to use for authentication" required="false" />
		<cfargument name="clientId" type="string" hint="the YubiCo Client ID to pass to the web service" required="false" />
		
		<cfif structKeyExists(arguments,"yubiCoURL")>
			<cfset setYubiCoURL(arguments.yubiCoURL) />
		<cfelse>
			<cfset setYubiCoURL("http://api.yubico.com/wsapi/") />
		</cfif>
		
		<cfif structKeyExists(arguments,"clientId")>
			<cfset setClientId(arguments.clientId) />
		<cfelse>
			<cfset setClientId(16) />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>

</cfcomponent>