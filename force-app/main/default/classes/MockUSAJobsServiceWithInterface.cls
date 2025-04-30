@isTest
global class MockUSAJobsServiceWithInterface implements IUSAJobsService, HttpCalloutMock {
    // Implement the IUSAJobsService interface
    global void getJobs() {
        // This method will be called during testing instead of the actual getJobs()
        // We don't need to make an actual HTTP call here. The HttpCalloutMock's
        // respond method will handle the mock response.
    }

    // Implement the HttpCalloutMock interface
    global HttpResponse respond(HttpRequest request) {
        // Create a new HttpResponse object for the mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); // Set the Content-Type header
        res.setStatusCode(200); // Simulate a successful HTTP response

        // Define the mock JSON response body
        String responseBody = '{' +
            '   "SearchResult": [' +
            '       {' +
            '           "JobTitle": "Software Engineer", ' +
            '           "OrganizationName": "National Aeronautics and Space Administration", ' +
            '           "LocationName": "Huntsville, AL"' +
            '       },' +
            '       {' +
            '           "JobTitle": "Data Scientist", ' +
            '           "OrganizationName": "Federal Bureau of Investigation", ' +
            '           "LocationName": "Quantico, VA"' +
            '       }' +
            '   ]' +
            '}';
        res.setBody(responseBody); // Set the mock response body

        return res; // Return the mock HttpResponse
    }

    // You can add more methods or logic here if your interface evolves
    // or if you need to simulate different outcomes.
}