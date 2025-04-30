public class USAJobsService {
    // Store parsed jobs for test validation
    public static List<Map<String, String>> parsedJobs = new List<Map<String, String>>();

    public static void getJobs() {
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        String endpoint = 'callout:USAJOBS_API/api/search?Keyword=developer&LocationName=Washington%2C%20DC';
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        try {
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                parseJobData(res.getBody());
            } else {
                System.debug('Callout failed. Status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void parseJobData(String responseBody) {
        parsedJobs.clear();  // Clear any previous results
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (jsonResponse.containsKey('SearchResult')) {
            List<Object> jobs = (List<Object>) jsonResponse.get('SearchResult');
            for (Object obj : jobs) {
                Map<String, Object> job = (Map<String, Object>) obj;
                Map<String, String> jobInfo = new Map<String, String>{
                    'JobTitle' => String.valueOf(job.get('JobTitle')),
                    'OrganizationName' => String.valueOf(job.get('OrganizationName')),
                    'LocationName' => String.valueOf(job.get('LocationName')),
                    'WhoMayApply' => String.valueOf(job.get('WhoMayApply')),
                    'HiringPath' => String.valueOf(job.get('HiringPath'))
                };
                parsedJobs.add(jobInfo);
            }
        } else {
            System.debug('No SearchResult key found in response.');
        }
    }
}
