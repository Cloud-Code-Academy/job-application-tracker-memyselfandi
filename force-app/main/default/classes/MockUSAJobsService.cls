@isTest // Annotation indicating this is a test class
global class MockUSAJobsService implements HttpCalloutMock {
    // Implement the HttpCalloutMock interface, required for mocking HTTP callouts

    global HttpResponse respond(HttpRequest request) {
        // This method is called by the test framework when an HTTP callout is made
        // A new HttpResponse object is created to simulate the API response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); // Set the Content-Type header to application/json
        res.setStatusCode(200); // Set the status code to 200, indicating a successful response

        // Define the mock response body (example of a successful response)
        String responseBody = '{' +
            '   "SearchResult": [' +
            '       {' +
            '           "JobTitle": "Software Developer", ' +
            '           "OrganizationName": "Department of Veterans Affairs", ' +
            '           "LocationName": "Washington, DC"' +
            '       },' +
            '       {' +
            '           "JobTitle": "Java Developer", ' +
            '           "OrganizationName": "U.S. Geological Survey", ' +
            '           "LocationName": "Reston, VA"' +
            '       }' +
            '   ]' +
            '}';
        res.setBody(responseBody); // Set the body of the mock response

        return res; // Return the mock HttpResponse object
    }

    // You could add more methods here to simulate different scenarios
    // (e.g., a method that returns an error response)
}