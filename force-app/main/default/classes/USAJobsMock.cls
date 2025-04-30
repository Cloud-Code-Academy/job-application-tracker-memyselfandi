@isTest
global class USAJobsMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{' +
                    '  "SearchResult": [' +
                    '    {' +
                    '      "JobTitle": "Salesforce Developer",' +
                    '      "OrganizationName": "Department of Tech",' +
                    '      "LocationName": "Washington, DC"' +
                    '    },' +
                    '    {' +
                    '      "JobTitle": "Apex Engineer",' +
                    '      "OrganizationName": "Federal IT",' +
                    '      "LocationName": "Washington, DC"' +
                    '    }' +
                    '  ]' +
                    '}'
                );
        return res;
    }
}
