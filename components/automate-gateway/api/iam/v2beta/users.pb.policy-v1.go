// Code generated by protoc-gen-policy. DO NOT EDIT.
// source: components/automate-gateway/api/iam/v2beta/users.proto

package v2beta

import (
	policy "github.com/chef/automate/components/automate-gateway/api/authz/policy"
	request "github.com/chef/automate/components/automate-gateway/api/iam/v2beta/request"
)

func init() {
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/CreateUser", "auth:users", "create", "POST", "/iam/v2beta/users", func(unexpandedResource string, input interface{}) string {
		if m, ok := input.(*request.CreateUserReq); ok {
			return policy.ExpandParameterizedResource(unexpandedResource, func(want string) string {
				switch want {
				case "id":
					return m.Id
				case "name":
					return m.Name
				case "password":
					return m.Password
				default:
					return ""
				}
			})
		}
		return ""
	})
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/GetUsers", "auth:users", "read", "GET", "/iam/v2beta/users", func(unexpandedResource string, input interface{}) string {
		return unexpandedResource
	})
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/GetUser", "auth:users:{id}", "get", "GET", "/iam/v2beta/users/{id}", func(unexpandedResource string, input interface{}) string {
		if m, ok := input.(*request.GetUserReq); ok {
			return policy.ExpandParameterizedResource(unexpandedResource, func(want string) string {
				switch want {
				case "id":
					return m.Id
				default:
					return ""
				}
			})
		}
		return ""
	})
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/DeleteUser", "auth:users:{id}", "delete", "DELETE", "/iam/v2beta/users/{id}", func(unexpandedResource string, input interface{}) string {
		if m, ok := input.(*request.DeleteUserReq); ok {
			return policy.ExpandParameterizedResource(unexpandedResource, func(want string) string {
				switch want {
				case "id":
					return m.Id
				default:
					return ""
				}
			})
		}
		return ""
	})
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/UpdateUser", "auth:users:{id}", "update", "PUT", "/iam/v2beta/users/{id}", func(unexpandedResource string, input interface{}) string {
		if m, ok := input.(*request.UpdateUserReq); ok {
			return policy.ExpandParameterizedResource(unexpandedResource, func(want string) string {
				switch want {
				case "id":
					return m.Id
				case "name":
					return m.Name
				case "password":
					return m.Password
				default:
					return ""
				}
			})
		}
		return ""
	})
	policy.MapMethodTo("/chef.automate.api.iam.v2beta.Users/UpdateSelf", "users:{id}", "update", "PUT", "/iam/v2beta/self/{id}", func(unexpandedResource string, input interface{}) string {
		if m, ok := input.(*request.UpdateSelfReq); ok {
			return policy.ExpandParameterizedResource(unexpandedResource, func(want string) string {
				switch want {
				case "id":
					return m.Id
				case "name":
					return m.Name
				case "password":
					return m.Password
				case "previous_password":
					return m.PreviousPassword
				default:
					return ""
				}
			})
		}
		return ""
	})
}
