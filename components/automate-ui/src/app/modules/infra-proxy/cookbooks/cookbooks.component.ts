import { Component, Input, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';
import { Observable, combineLatest } from 'rxjs';
import { NgrxStateAtom } from 'app/ngrx.reducers';
import { LayoutFacadeService, Sidebar } from 'app/entities/layout/layout.facade';
import { filter } from 'rxjs/operators';
import { isNil } from 'lodash/fp';
import { EntityStatus, allLoaded } from 'app/entities/entities';
import { GetCookbooksForOrg } from 'app/entities/cookbooks/cookbook.actions';
import { Cookbook } from 'app/entities/cookbooks/cookbook.model';
import {
  allCookbooks,
  getAllStatus as getAllCookbooksForOrgStatus
} from 'app/entities/cookbooks/cookbook.selectors';

@Component({
  selector: 'app-cookbooks',
  templateUrl: './cookbooks.component.html',
  styleUrls: ['./cookbooks.component.scss']
})

export class CookbooksComponent implements OnInit {
  @Input() serverId: string;
  @Input() orgId: string;

  public cookbooks: Cookbook[] = [];
  public loading$: Observable<boolean>;
  public sortedCookbooks$: Observable<Cookbook[]>;
  public isLoading = true;
  public cookbooksListLoading = true;

  constructor(
    private store: Store<NgrxStateAtom>,
    private layoutFacade: LayoutFacadeService
  ) { }

  ngOnInit() {
    this.layoutFacade.showSidebar(Sidebar.Infrastructure);

    this.store.dispatch(new GetCookbooksForOrg({
      server_id: this.serverId, org_id: this.orgId
    }));

    combineLatest([
      this.store.select(getAllCookbooksForOrgStatus)
    ]).pipe().subscribe(([getCookbooksSt]) => {
        this.isLoading = !allLoaded([getCookbooksSt]);
      });

    combineLatest([
      this.store.select(getAllCookbooksForOrgStatus),
      this.store.select(allCookbooks)
    ]).pipe(
      filter(([getCookbooksSt, _allCookbooksState]) =>
        getCookbooksSt === EntityStatus.loadingSuccess && !isNil(_allCookbooksState))
    ).subscribe(([ _getCookbooksSt, allCookbooksState]) => {
      this.cookbooks = allCookbooksState;
      this.cookbooksListLoading = false;
    });
  }
}
