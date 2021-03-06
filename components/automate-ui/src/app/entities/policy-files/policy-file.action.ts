import { HttpErrorResponse } from '@angular/common/http';
import { Action } from '@ngrx/store';
import { PolicyFile } from './policy-file.model';

export enum PolicyFileActionTypes {
  GET_ALL = 'POLICYFILES::GET_ALL',
  GET_ALL_SUCCESS = 'POLICYFILES::GET_ALL::SUCCESS',
  GET_ALL_FAILURE = 'POLICYFILES::GET_ALL::FAILURE'
}

export interface PolicyFilesSuccessPayload {
  policies: PolicyFile[];
}

export class GetPolicyFiles implements Action {
  readonly type = PolicyFileActionTypes.GET_ALL;
  constructor(public payload: { server_id: string, org_id: string }) { }
}

export class GetPolicyFilesSuccess implements Action {
  readonly type = PolicyFileActionTypes.GET_ALL_SUCCESS;
  constructor(public payload: PolicyFilesSuccessPayload) { }
}

export class GetPolicyFilesFailure implements Action {
  readonly type = PolicyFileActionTypes.GET_ALL_FAILURE;
  constructor(public payload: HttpErrorResponse) { }
}

export type PolicyFileActions =
  | GetPolicyFiles
  | GetPolicyFilesSuccess
  | GetPolicyFilesFailure;
