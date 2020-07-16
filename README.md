## Functionalities
#### UI
1. Sign up
2. Log in
3. Upload a csv file of keywords (can either be 1 or multiple rows)
    - CSV example:
    ```
        buy helmet, get car, find ipad
        macbook, iphone, pixel
    ```

4. View a report page of keywords searched with the corresponding data:
    - number of ads
    - number of links
    - number of all results
    - searched time

#### Not on UI
- Save html of live page and cached page of each search result item on the first google search     

#### Crawler detail
- Using Watir and Chromedriver: open headless Chrome to go to search page and parse results
- Using Sidekiq for asynchronously crawling pages from different hosts
- Using Mutex-redis and thread sleep to prevent crawling a same host in a short duration
- Break time for crawling a same host is varied from 30s to 100s

#### Reason for not using simple parsers like Nokogiri
- Simply calling Google search and parsing the returned html by Nokogiri does not satisfy the
    requirements, as the result html lack the following information:
    - Total number of all results and search time (About 2,000,000 results in 0.40 seconds)
    - Ads
- **Personal note**: this may be Google's method to prevent scrawlers by not returning all data
    in one request 
    
#### Reason for using Watir
- Open search url in a real browser, thus bypass the above issue
- Open for future improvements by:
    - Opening the urls in different clients
    - Mimic real users by adding cookies

## Project Setup
- Build image: docker build -t crawler-base .
- Start docker-compose: docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
- Access a container: docker exec -it [container_name] bash
- Start these containers:
    - nimble_test_web: bin/start.sh
    - web-crawler: bundle exec sidekiq

## Issues
#### Current issues
1. Browser crashes
    - Error sample: __pid=1628 tid=ouh8dyyww WARN:
        Selenium::WebDriver::Error::UnknownError: unknown error: session deleted because of page crash__
2. Port is being used error
    - Error sample: __pid=12 tid=gs8ss76zg WARN:
        Errno::EADDRINUSE: Address already in use - bind(2) for "0.0.0.0" port 41075__
3. Closing browser makes zombies threads
4. Codebase is having lots of empty templates

#### Requirements not met
1. Merge code using pull requests
2. Write unit tests
3. Deploy the application to Heroku


