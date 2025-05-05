@isTest
public class USAJobsMock implements HttpCalloutMock {
    // This method is required by the HttpCalloutMock interface
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); // Simulate a JSON response
        res.setStatusCode(200); // Return HTTP 200 OK status

        // Mock JSON body structure matching the expected USAJobs API format
        String responseBody = '{' +
            '"SearchResult": {' +
                '"SearchResultItems": [' +
                    '{' +
                        '"MatchedObjectId": "123456",' +
                        '"MatchedObjectDescriptor": {' +
                            '"PositionTitle": "Salesforce Developer",' +
                            '"PositionURI": "https://example.com/123",' +
                            '"OrganizationName": "Department of Tech",' +
                            '"PositionRemuneration": [{' +
                                '"MinimumRange": "85000"' +
                            '}],' +
                            '"PositionLocation": [{' +
                                '"LocationName": "Washington, DC"' +
                            '}],' +
                            '"UserArea": {' +
                                '"Details": {' +
                                    '"MajorDuties": ["Develop Apex triggers", "Work with Lightning Web Components"]' +
                                '}' +
                            '}' +
                        '}' +
                    '}' +
                ']' +
            '}' +
        '}';

        res.setBody(responseBody); // Set the mock response body
        return res; // Return the mock HTTP response
    }
}
