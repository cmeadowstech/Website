# Website
For the Cloud Resume Challenge - https://cloudresumechallenge.dev/docs/the-challenge/azure/

1. ~~Certification~~
2. ~~HTML~~
3. ~~CSS~~
4. ~~Static Website~~
5. ~~HTTPS~~
6. ~~DNS~~
7. Javascript
8. Database
9. API
10. Python
11. Tests
12. Infrastructure as Code
13. Source Control
14. CI/CD (Back end)
15. CI/CD (Front end)
16. Blog post

---

In my efforts to pick up some skills with Azure, I came across the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/azure/) and thought I'd throw myself at it while studying for the AZ-104. It consists of several sections designed to throw you into various skills used when working in the Azure environment - blob storage, CDNs, programming with JavaScript and Python, and automation with Azure Functions and GitHub Actions.

I'm already somewhat familiar with HTML and CSS so while I'm not far into my Azure studies, the first few steps were pretty easy to bang out over the weekend. So here I present to you my new resume website - https://web.cmeadows.tech/

## Certification

I actually got the AZ-900 last summer. I know, a while between then in and but I was busy getting accustomed to my new L2 position. (There is no L3 at my company, next stop Microsoft) This was really an introductory certification anyways, not one that had you doing much of anything.

## HTML

I've put together a few websites over the years, so a simple static page was pretty quick to get together. It's mostly just some DIVs for each section, and some headers, paragraphs and unordered lists for the contents.

I mean, look at this. Not trying to undersell my work but I know people would scoff at this being called "web development"

```
	<div class="section">
	<h2 class="head">Certifications & Skills</h2>
		<ul>
			<li><b>Certifications:</b> CompTIA Network+, MS-900: Microsoft 365 Fundamentals, AZ-900: Microsoft Azure Fundamentals, CompTIA A+</li>
			<li><b>Skills:</b> Office 365, Azure, Active Directory, PowerShell, Exchange, DNS, Cloud Security, Remote Access Software, Windows 10, macOS, Android, Microsoft Office</li>
		</ul>
	</div>
```

## CSS

This is also pretty straight-forward. I used a basic reset template to normalize everything and made some minor flavor changes. A background image, centered resume, rounded corners, dashed borders. I might add some animation to it if I get bored. 

## Static Website

Getting into the fun stuff. I hadn't really done anything with blob storage when studying for the AZ-900. Azure Static Webpages made this real easy though - enable it and upload your files to the pre-configured $web container.

I did create a PowerShell script to upload my updated files though so I don't have to putz around in the portal. It seemed like most people used AzCopy for this, but I opted for Set-AzStorageBlobContent instead. Partly because I'm more comfortable with PowerShell, partly because I was worried how AzCopy integrates with GitHub Actions down the line.

```
Connect-AzAccount		# If you have multiple directories you will need to specify with -Tenant

# Set container and context below

$localfolder = "C:\your path here"
$storageAccount = Get-AzStorageAccount -ResourceGroupName "Your Resource Group" -Name "Name of storage account"
$Context = $storageAccount.context
$ContainerName = '$web'
$Storage = Get-AzStorageBlob -Context $Context -Container '$web'
$files = Get-ChildItem $localfolder

# Replace files if they exist, and upload them if they don't

foreach ($file in $files) {
    $name = $file.name
    $path = "$($localfolder)\$($name)"
    $blob = Get-AzStorageBlob -Container $ContainerName -Context $Context -Blob $name -ErrorAction:SilentlyContinue
    if ($blob -eq $null) {
        Set-AzStorageBlobContent -Container $ContainerName -Context $Context -File $path -Blob $name -Properties @{"ContentType" = [System.Web.MimeMapping]::GetMimeMapping($path)}    # If the file does not currently exist on the container
    } else {
        $blob | Set-AzStorageBlobContent -File $path -Properties @{"ContentType" = [System.Web.MimeMapping]::GetMimeMapping($path)} -Force    # If the file does currently exist on the container
    }
}

# Purge CDN Endpoint
Get-AzCdnProfile | Get-AzCdnEndpoint | Unpublish-AzCdnEndpointContent -PurgeContent "/*"	
```

## HTTPS

Configuring the CDN was easy, but setting up HTTPS was more of a pain than it should be in my opinion. I mean, enabling it for subdomains is a flip of a switch but it seems inordinately difficult to do so for a root domain. The only options are to buy an expensive certification from someone like DigiCert or a complex automated process to obtain and renew certificates from the common Let's Encrypt.

In the future I'll revisit automating Let's Encrypt certificates, but for now I'll opt to use a subdomain for my site.

## DNS

Azure DNS zones are pretty easy to set up. I had to set my nameservers in NameCheap, but other than that they have an easy gui to point your records to already existing resources like the CDN endpoint I previously configured.
