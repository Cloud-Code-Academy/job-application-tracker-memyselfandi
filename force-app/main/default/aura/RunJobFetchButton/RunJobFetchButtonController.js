({
    runLogic : function(component, event, helper) {
        // Get a reference to the Apex controller method 'runCustomLogic'
        var action = component.get("c.runCustomLogic");

        // No parameters need to be set here since the Apex method takes no arguments

        // Define the callback to handle the response from the server
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state (e.g., SUCCESS, ERROR)

            if (state === "SUCCESS") {
                // Close the Quick Action panel after successful server call
                $A.get("e.force:closeQuickAction").fire();

                // Show a success toast message
                $A.get("e.force:showToast").setParams({
                    "title": "Success",
                    "message": "Jobs fetched successfully.",
                    "type": "success"
                }).fire();
            } else {
                // Show an error toast message if the server call fails
                $A.get("e.force:showToast").setParams({
                    "title": "Error",
                    "message": "Something went wrong.",
                    "type": "error"
                }).fire();
            }
        });

        // Enqueue the action to send it to the server
        $A.enqueueAction(action);
    }
})