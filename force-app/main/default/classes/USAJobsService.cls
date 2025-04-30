public with sharing class USAJobsService {
    // Method to get job listings from USAJOBS API
    public static void getJobs() {
        HttpRequest req = new HttpRequest(); // Create a new HTTP request object
        Http http = new Http(); // Create an HTTP client to send the request
    
        String endpoint = 'callout:USAJOBS_API/api/search?Keyword=developer&LocationName=Washington%2C%20DC'; 
        // Named Credential 'USAJOBS_API' handles the base URL and authentication headers
    
        req.setEndpoint(endpoint); // Set the full API endpoint (with Named Credential prefix)
        req.setMethod('GET'); // Set the HTTP method to GET
        req.setHeader('Accept', 'application/json'); // Tell the server we want a JSON response
    
        try {
            HttpResponse res = http.send(req); // Send the HTTP request and get the response
    
            if (res.getStatusCode() == 200) { // If successful (HTTP 200 OK)
                parseJobData(res.getBody()); // Parse and process the JSON response body
            } else {
                System.debug('Callout failed. Status code: ' + res.getStatusCode()); // Log failure status
                System.debug('Response: ' + res.getBody()); // Log full response for debugging
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage()); // Catch and log any unexpected errors
        }
    }
    

    // Helper method to parse and log job data from the response
    public static void parseJobData(String responseBody) {
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody); 
        // Parse the raw JSON string into a generic Map for flexible key access
    
        if (jsonResponse.containsKey('SearchResult')) { 
            // Check if the JSON response contains the key 'SearchResult'
    
            List<Object> jobs = (List<Object>) jsonResponse.get('SearchResult'); 
            // Extract the list of jobs from the 'SearchResult' key
    
            for (Object obj : jobs) { 
                // Loop through each job entry
    
                Map<String, Object> job = (Map<String, Object>) obj; 
                // Cast each job to a Map to access its fields
    
                System.debug('Job Title: ' + job.get('JobTitle')); 
                // Log the job title to the debug output
    
                System.debug('Company: ' + job.get('OrganizationName')); 
                // Log the organization/company name
    
                System.debug('Location: ' + job.get('LocationName')); 
                // Log the job location
            }
        } else {
            System.debug('No SearchResult key found in response.'); 
            // Log a message if the expected key is missing from the response
        }
    }    
}