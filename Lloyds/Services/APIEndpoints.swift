//
//  Untitled 2.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//


enum WorkflowDetailType {
    case permit
    case incident
}




struct APIEndpoints {
    // MARK: - Auth
    static var login: String {
        //        return APIConfig.baseURL + "v1/auth/signin/"
        return APIConfig.loginURL
    }
    
    static var refreshToken: String {
        APIConfig.baseURL + "v1/auth/get-refresh-token"
    }
    
    
    
    
    // MARK: - Permits
    static var permitsV1: String {
        return APIConfig.baseURL + "v1/workflow/permits"
    }
    
    static var permitsForMe: String {
        return APIConfig.baseURL + "v2/workflow/check-user"
    }
    static var changePassword: String {
        APIConfig.baseURL + "v1/auth/change_password"
    }
    
    // MARK: - Helpers
    
    static func allPermits(status: String?, startDate: String, endDate: String, offset: Int = 0) -> String {
        return "\(permitsV1)?offset=\(offset)&status=\(status ?? "null")&startDate=\(startDate)&endDate=\(endDate)"
    }
    
    static func myPermits(status: String?, startDate: String, endDate: String) -> String {
        return "\(permitsForMe)?status=\(status ?? "null")&startDate=\(startDate)&endDate=\(endDate)"
    }
    
    
    static var permitDetail: String {
        APIConfig.baseURL + "v1/workflow/permit"
    }       // Single permit by id (add ?permit_id=xxx)
    
//    static func permitDetails(permitId: Int) -> String {
//        return APIConfig.baseURL + "v1/workflow/permit/details?permit_id=\(permitId)"
//    }
    
    static func permitDetails(
        permitId: Int,
        type: WorkflowDetailType = .permit
    ) -> String {

        switch type {

        case .permit:
            return APIConfig.baseURL +
            "v1/workflow/permit/details?permit_id=\(permitId)"

        case .incident:
            return APIConfig.baseURL +
            "v1/workflow/auxiliary/permit/details?permit_id=\(permitId)"
        }
    }
    
    static var uploadPermit: String {
        APIConfig.baseURL + "v1/workflow/permit"
    }
    
    static func uploadAfterImage(fileName: String) -> String {
        APIConfig.baseURL + "v1/amazon-s3/upload-image?fileName=\(fileName)"
       }
    
    static var uploadToS3: String {
        APIConfig.baseURL + "v1/amazon-s3/upload-image"
    }
    
    static var padlockList: String {
        APIConfig.baseURL + "v1/web/padlock"
    }
    
    static var isolationList: String {
        APIConfig.baseURL + "v2/isolation-point/isolation"
    }
    
    static var uploadImage: String {
        APIConfig.baseURL + "v1/amazon-s3/upload-image"
    }
    
    static var permit: String {
        APIConfig.baseURL + "v1/workflow/permit"
    }
    
    static var userList: String {
        APIConfig.baseURL + "v1/workflow/users"
    }
    
    //    /v2/face-auth/verify-workmen
    //     /v2/face-auth/get-technicians-list
    static var faceauth: String {
        APIConfig.baseURL + "v2/face-auth/verify-workmen"
    }
    
    static var technicianslist: String {
        APIConfig.baseURL + "v2/face-auth/get-technicians-list"
    }
    
    static var faceAuthUpload: String {
        APIConfig.baseURL + "v2/face-auth/register"
    }
    
    //    v2/face-auth/verify
    static var faceauthverify: String {
        APIConfig.baseURL + "v2/face-auth/verify"
    }
    
    static var Padlockconnect: String {
        APIConfig.baseURL + "v1/web/padlock"
    }
    
    static var tuyaWorkflow: String {
        APIConfig.baseURL + "v1/workflow/tuya"
    }
    
    
    // MARK: - Documents / Images

    static func preSignedImageURL(key: String) -> String {
        return APIConfig.baseURL + "v2/documents/download/pre-signed-url?key=\(key)"
    }
    
    
    // MARK: - Auxiliary Permit (Incident Update)

    static var auxiliaryPermit: String {
        return APIConfig.baseURL + "v1/workflow/auxiliary/permit"
    }
    
    
    // MARK: - Permit History

    static func permitHistory(permitId: Int) -> String {
        return APIConfig.baseURL + "v1/workflow/permit/history?permit_id=\(permitId)"
    }
    
    static var incidentPermitAction: String {
        return APIConfig.baseURL + "v1/workflow/auxiliary/permit"
    }
    
    // MARK: - OM (Functional Location)

    static var functionalLocations: String {
        return APIConfig.baseURL + "v1/om/functional-location"
    }
    
    // MARK: - Incident

    static var createIncident: String {
        return APIConfig.baseURL + "v2/workflow/auxiliary/newpermit"
    }
    
    // MARK: - Permit

    static var createPermit: String {
        return APIConfig.baseURL + "v2/workflow/newpermit"
    }
    
    // MARK: - Permit Actions

    static var permitWorkflowAction: String {
        return APIConfig.baseURL + "v1/workflow/permit"
    }
    
    // MARK: - Incident Detail

    static func incidentDetail(permitId: Int) -> String {
        return APIConfig.baseURL + "v1/workflow/auxiliary/permit?permit_id=\(permitId)"
    }
    
    // MARK: - Incident Form

    static func incidentForm() -> String {
        return APIConfig.baseURL + "v1/forms/newpermit/type"
    }
    
    
    // MARK: - Incident Permits List
       static func incidentPermits(
           start: String,
           end: String,
           offset: Int
       ) -> String {
           return APIConfig.baseURL +
           "v1/workflow/auxiliary/permits" +
           "?status=null" +
           "&startDate=\(start)" +
           "&endDate=\(end)" +
           "&plantRequired=false" +
           "&offset=\(offset)"
       }

       // MARK: - Permit Detail
       static func permitDetail(permitId: Int) -> String {
           return APIConfig.baseURL +
           "v1/workflow/permit?permit_id=\(permitId)"
       }

       // MARK: - Incident Detail
       static func incidentDetaill(permitId: Int) -> String {
           return APIConfig.baseURL +
           "v1/workflow/auxiliary/permit?permit_id=\(permitId)"
       }
    
    
}

extension APIConfig {
    static var updatePermitURL: String {
        baseURL + "v1/workflow/permit"
    }
    
    
    //for all company
//    static func companyPolygon(name: String) -> String {
//            baseURL + "v1/company/all?name=\(name)"
//        }
    
    static func companyPolygon(name: String) -> String {
            baseURL + "v1/company/all?name=wonder_cement"
        }
    
    
    
    static func campaignodetails(name: String) -> String {
            baseURL + "v1/company/all?name=wonder_cement"
        }
    
   
    
    
    
    
    
}
