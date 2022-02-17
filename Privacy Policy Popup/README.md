# Privacy Policy Popup

This document will detail how to, using Turn Automations, create a popup that will show the user the privacy policy, but only for the first time they interact with the service, or the first time that they interact after this has been implemented, for the case of adding this to an existing service.

## Privacy policy popup rule

This first rule is for sending the privacy policy to the user.

First, you'll want to create a new contact field to track whether or not the user has seen the privacy policy, in this case we've named it "Privacy Policy Exposure". This can either be a text field defaulting to empty, or a yes/no boolean field defaulting to no. For the text field, empty will mean that the user hasn't seen the policy, and a value of "True" will mean that they have.

Then you'll want to create a piece of content. This will be the message (and also possibly the attachment) that we'll be sending to the user as a popup.

You'll want to start by adding a trigger.
1. Message received
2. Contact with a specific profile
3. The following field on the contact: "Privacy policy exposure" (or whatever name you've chosen)
4. Should exactly match the following value: "No value" (or "no" for the yes/no boolean field)

This trigger should look like

![image](https://user-images.githubusercontent.com/8234653/154502765-a32214b8-b927-4b4a-a651-ff8ec9e6694f.png)

Then there are 2 actions that we'll need to add. The first action is responsible for sending the user the privacy popup:
1. Reply with a message
2. Select the popup content that contains the privacy policy that you created

This action should look like:

![image](https://user-images.githubusercontent.com/8234653/154503837-e4a4d7b8-5ff8-4ecc-9582-98439fd970fb.png)

And the second action is for updating the contact, so that we know that they've seen the privacy policy. It is this step that ensures that they'll only be shown the privacy policy once.
1. Update a field on a contact
2. The following field on a contact: "Privacy policy exposure" (or whatever name you've chosen)
3. Should set the following value: "True" (or "yes" for the yes/no boolean field)

This action should look like:

![image](https://user-images.githubusercontent.com/8234653/154504441-0c05b558-2787-41bf-a12a-c6cc2200cbb0.png)

Then you can give your automation a name, and click "Activate" to save and activate the automation.
