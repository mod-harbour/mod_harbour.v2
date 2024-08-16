To integrate Google sign-in into your web app, follow these steps:

Step 1: Set Up Your Project in Google Cloud Console
Create a New Project

Go to the Google Cloud Console.
Click on “New Project” and give it a name.
Click “Create.”

In the Cloud Console, go to the OAuth consent screen.
Choose “External” and click “Create.”
Fill in the required information:
App name: Enter your app’s name.
User support email: Enter an email address for user support.
Developer contact information: Enter your email address.

Add Scopes
Add the required scopes for your app. For Google sign-in, you'll typically need:
email
profile
openid

Test Users( needed for testing )

Add test users if needed (these are users who can test your app before it’s published).

Step 2: Create OAuth 2.0 Credentials
Create Credentials

In the Cloud Console, go to the Credentials page.
Click “Create Credentials” and select “OAuth 2.0 Client IDs.”
Choose “Web application” as the application type.
Fill in the required fields:
Authorized JavaScript origins: Enter the URLs from where your web app will be making requests (e.g., http://localhost:port for local development).
Authorized redirect URIs: Enter the redirect URIs for your app (e.g. for test, http://localhost:port/Samples/goauth/index.prg).

Save Your Credentials

Click “Create.”
You will see your Client ID and Client Secret. Download Oauth client .json and use for the sample. credentials.json

