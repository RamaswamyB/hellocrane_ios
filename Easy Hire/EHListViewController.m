//
//  EHListViewController.m
//  Easy Hire
//
//  Created by Prasanna on 24/02/16.
//  Copyright © 2016 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHListViewController.h"
#import "EHHTTPClient.h"

@implementation ListModel
@end

@interface EHListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, assign) int code;

@end


@implementation EHListViewController
{
    NSMutableArray *listArray;
    NSMutableArray *searchData;
    UIRefreshControl *refreshControl;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}
- (instancetype)initWithListCode:(int)listCode
{
    if (self = [super init]) {
        _code = listCode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    listArray = [[NSMutableArray alloc] initWithCapacity:kNilOptions];
    searchData = [[NSMutableArray alloc] init];


    _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listTableView.dataSource = self;
    _listTableView.delegate = self;
    [self.view addSubview:_listTableView];

    if (_code == kCapacity) {
        self.title = @"Capacity";
        [self sendQueryForURL:CAPACITY_URL forClientMethod:@"GET"];
    }
    
    else
    {
        self.title = @"Brand";
        [self sendQueryForURL:BRAND_URL forClientMethod:@"GET"];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_listTableView addSubview:refreshControl];
    
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    _listTableView.tableHeaderView = searchBar;

}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    _listTableView.frame = bounds;
}
- (void)refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl endRefreshing];
    
    if (_code == kCapacity) {
        [self sendQueryForURL:CAPACITY_URL forClientMethod:@"GET"];
    }
    else
    {
        [self sendQueryForURL:BRAND_URL forClientMethod:@"GET"];
    }
}
- (void)sendQueryForURL:(NSString *)url forClientMethod:(NSString *)method
{
    weakify(self);
    
    EHHTTPClient *serviceClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        NSDictionary *dictionary = nil;
        return dictionary;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:@"Message!"];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            [listArray removeAllObjects];
            
            NSLog(@"Equipemnt %@",[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                NSArray *keys = [dict[@"data"] allKeys];
                
                for (NSString *key in keys) {
                    
                    ListModel *model = [[ListModel alloc] init];
                    model.listID = key;
                    model.listName = dict[@"data"][key];
                    [listArray addObject:model];
                }
                
            }
            
            if (listArray.count <= kNilOptions) {
                
                if (self.code == kCapacity) {
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"No capacity list available" cancelButtonTitle:@"OK" otherButtonTitles:nil completionBlock:nil];
                }
                else
                {
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"No brand list available" cancelButtonTitle:@"OK" otherButtonTitles:nil completionBlock:nil];
                }
            }
            
            // Reload
            [self.listTableView reloadData];
        }
        
    }];
    [serviceClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _listTableView) {
        return listArray.count;
    }
    else
    {
      return  searchData.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"aCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    
    if (tableView == _listTableView) {
        ListModel *model = listArray[indexPath.row];
        cell.textLabel.text = model.listName;
    }
    else
    {
        ListModel *model = searchData[indexPath.row];
        cell.textLabel.text = model.listName;
    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selectedIndex:forModel:)]) {
        
        if (tableView == _listTableView) {
            [self.delegate selectedIndex:_code forModel:listArray[indexPath.row]];
        }
        else
        {
            [self.delegate selectedIndex:_code forModel:searchData[indexPath.row]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - searchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [searchData removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"listName CONTAINS[cd] %@",searchString];
    NSArray *array = [listArray filteredArrayUsingPredicate:predicate];
    [searchData addObjectsFromArray:array];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
