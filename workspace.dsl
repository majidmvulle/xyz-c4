!const ORGANISATION_NAME "XYZ Enterprises"
!const TECHNOLOGY_JSON_HTTPS "json/https"
!const TECHNOLOGY_REST "REST API"

workspace {

    model {
        customer = person "Customer"
        staff = person "Staff"

        awsS3Ss = softwareSystem "AWS S3" "An object storage service by Amazon AWS" "Existing System"

        xyzSs = softwareSystem "${ORGANISATION_NAME}" {
            immuDB = container  "ImmuDB" "an open-source high performance immutable database" "odbc" "Database"{
                this -> awsS3Ss "uses (for storage)"
            }

            customerWebsite = container "Customer Website" "Provides functionality for customers" "reactjs*" "Browser" {
                customer -> this "uses"
            }  

            staffDashboard = container "Staff Dashboard*" "Provides functionality for staff" "reactjs*" "Browser" {
                staff -> this "uses"
            }  

            group "on-prem"{
                servicesApp = container "Services Service*"
                usersApp = container "Users Service*"
                paymentsApp = container "Payments Service*"
                authApp = container "Auth Service*"
            } 

            group "AWS Europe (London) Region"{
                loyaltyApp = container "Loyalty Service" {
                    pointsComponent = component "Points Component" "provides functionality related to managing, earning and redeeming Reward points" "golang" {
                        this -> immuDB "reads from and writes to" "odbc"
                    }
                    pointsController = component "Points Controller" "allows users to earn and redeem Reward points, staff to manage Rewards points" "golang/gin REST Controller"{
                        this -> pointsComponent "uses"
                        customerWebsite -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                        staffDashboard -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                    }   
                    
                    transactionsComponent = component "Transactions Component" "creates, reads, updates transactions" "golang" {
                        this -> immuDB "reads from and writes to" "odbc"
                    }
                    transactionsController = component "Transactions Controller" "functionality to manage transactions" "golang/gin REST Controller"{
                        this -> transactionsComponent "uses"
                        customerWebsite -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                        staffDashboard -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                    }

                    servicesComponent = component "Products Component" "queries Service details from on-prem" "golang" {
                        this -> immuDB "reads from and writes to" "odbc"
                        this -> servicesApp "queries Services" "${TECHNOLOGY_REST}"
                    } 

                    usersComponent = component "Users Component" "queries User details from on-prem" "golang" {
                        this -> immuDB "reads from and writes to" "odbc"
                        this -> usersApp "queries Users" "${TECHNOLOGY_REST}"
                        usersApp -> this "sends a request on user deactivation/reactivation" "webhook"
                    }  
                    usersController = component "Users Controller" "functionality to manage user references in the loyalty program" "golang/gin REST Controller"{
                        this -> usersComponent "uses"
                        customerWebsite -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                        staffDashboard -> this "makes API calls to" "${TECHNOLOGY_JSON_HTTPS}"
                    }
                    
                    paymentsComponent = component "Payments Component" "queries Payment details from on-prem" "golang" {
                        this -> immuDB "reads from and writes to" "odbc"
                        this -> paymentsApp "queries Payments" "${TECHNOLOGY_REST}"
                        paymentsApp -> this "sends a request on payment success/reversal" "webhook"
                    }

                    authComponent = component "Auth Component" "authorizes access by verifying the JWT in Authorization header" "golang" {
                        this -> authApp "sends a request to access the JSON Web Key Sets (JWK)" "HTTP"
                    }
                }
            }
        }
    }

    views {
        systemContext xyzSs {
            include *
        }

        container xyzSs {
            include *
        }

        component loyaltyApp "Components"{
            include *

            include "* -> *"
        }


        styles {
            element "MobilePotrait" {
                shape mobiledeviceportrait
                background #ffffff
            }
            element "MobileLandscape"{
                shape mobiledevicelandscape
            }
            element "Browser" {
                shape webbrowser
            }
            element "Database" {
                shape cylinder
            }            
            element "Robot" {
                shape robot
            }           
            element "Folder" {
                shape folder
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Existing System Robot" {
                shape robot                
                background #999999
                color #ffffff
            }
        }

        theme default
    }

}