//
//  MapPositionController.m
//  WeJuBar
//
//  Created by JoyDo on 15/3/25.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "MapPositionController.h"
#import "WJPOIAnnotation.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "MJRefresh.h"


#define DefaultLocationTimeout  6
#define DefaultReGeocodeTimeout 3

@interface MapPositionController () <MAMapViewDelegate,UISearchBarDelegate,UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,MAMapViewDelegate,AMapLocationManagerDelegate
> {
    
     NSMutableArray *poiResultArr; //poi 周边数据源
     BOOL bClickCellMakeMoveFlag; //是否为点击cell使移动
     UITableViewCell *lastMarkCell;//上一次点击的cell
     WeJuBarPoi *lastMarkPOI; //上一次选中的POI
     WeJuBarPoi *targetPoi; //移动的地理位置名称
     NSInteger currentPoiPage; //当前poi页数
     BOOL bTargetPoiHasAddToPoiResultArr; //标识 手动让mapView移动后，位置是否已经添加进来。 注意：（切换新位置的时候，参数要回归。）
     CGFloat chooseOriginY;
    
    //加载视图
    UIImageView *loadingIconImageView;
    NSInteger iLoadingState;
    CADisplayLink *rotationDisplayLink;
    CGFloat fRotation;
    BOOL reloading;
    
    //搜索标记
    NSMutableArray *searchResultArr; //搜索的数据源
    BOOL isClickCancelTag;
    BOOL isClickSearchTag;
    int isShowResultTag;
    
    //搜索
    NSString *customerSearchText;
    NSString *targetCity;
}
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;
@property (nonatomic, strong) CLLocation *currentLocation; //当前用户坐标

@end

@implementation MapPositionController


-(void)initDatas{
    
    currentPoiPage = 1;
    poiResultArr =  [[NSMutableArray alloc]init];
    searchResultArr =  [[NSMutableArray alloc]init];
    
    //监听键盘隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Map choose position";
    
    [self initDatas];
    
    //搜索条
    [self initSearchBar];
    
    //SearchDisplay
    [self initSearchDisplay];
    
    //地图
    _mapView = [[MAMapView alloc] init];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES; //打开定位
    _mapView.showsCompass = NO; //设置成NO表示关闭指南针
    //设置高德地图logo位置
    //_mapView.logoCenter = CGPointMake(CGRectGetWidth(self.view.bounds)-55, _mapView.frame.size.height - 15);
    [_mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    _mapView.showsScale = NO; //关闭比例尺
   // [_mapView setUserTrackingMode: MAUserTrackingModeNone animated:YES]; //不跟随位置移动
    [self.view addSubview:_mapView];
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(_searchBgView.mas_bottom);
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-260);
    }];
    
    
    //userButton
    _userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_userLocationButton setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    _userLocationButton.backgroundColor = [UIColor clearColor];
    [_userLocationButton addTarget:self action:@selector(backUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:_userLocationButton];
    
    [_userLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.and.with.equalTo(@40);
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-15);
    }];
    
    //searchBar
    [self initSearch];
   
    //标注
    if (_locationImageView == nil) {
        _locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location"]];
        
    }
    [self.view addSubview:_locationImageView];
    [_locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_mapView);
    }];
    

    //chooseResultTable
    [self  createChooseResultTable];
    
    //获得位置
    if(_currentLocation == nil){
        
        [self initCompleteBlock];
        [self configLocationManager];
        
       // [self getLocation];
    }else{
        [self setMapCenter:_currentLocation.coordinate];
    }
    
    //加载中动画
    if(loadingIconImageView == nil)
    {
        CGFloat width = 25 , height = 25;
        CGFloat x = SCREEN_W / 2 ;
        CGFloat y = CGRectGetMaxY(_mapView.frame) + _mapView.frame.size.height/ 4;
        loadingIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        loadingIconImageView.image = [UIImage imageNamed:@"loading.png"];
        loadingIconImageView.alpha = 0.0;
        [self.view addSubview:loadingIconImageView];
    }
    [self beginLoadingAnimation];
}

-(void)addRightBarButtonItem
{
    UIButton *addMapAnimationView = [UIButton buttonWithType:UIButtonTypeCustom];
    addMapAnimationView.frame = CGRectMake(0, 0, 50, 35);
    addMapAnimationView.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [addMapAnimationView setTitle:@"alert" forState:UIControlStateNormal];
    [addMapAnimationView setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];
    [addMapAnimationView addTarget:self action:@selector(choosePoi) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:addMapAnimationView];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Initialization
- (void)initSearchBar
{
    //搜索条
    _searchBgView = [[UIView alloc] init];
    if(_searchBar == nil)
    {
        _searchBar = [[UISearchBar  alloc] init];
        _searchBar.tintColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.keyboardType =UIKeyboardTypeDefault;
        _searchBar.delegate = self;
        _searchBar.translucent = YES;
        _searchBar.showsScopeBar=YES;
        [_searchBar setBackgroundImage:[UIImage new]];
        [_searchBar setTranslucent:YES];
        _searchBar.backgroundColor = UIColorRGB(234, 234, 234);
        NSString *placeholdStr= @"Search or enter an address";
        _searchBar.placeholder=[NSString stringWithCString:[placeholdStr cStringUsingEncoding:NSUTF8StringEncoding]  encoding: NSUTF8StringEncoding];
        
    }
    
    //调整取消按钮的颜色
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)],UITextAttributeTextShadowOffset,nil] forState:UIControlStateNormal];
    
    [self.view addSubview:_searchBgView];
    [_searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.right.mas_equalTo(0);
        make.height.equalTo(@44);
    }];
    
    [_searchBgView addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.and.left.and.right.and.bottom.mas_equalTo(0);
    }];
}

- (void)initSearchDisplay
{
    _displayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _displayController.delegate                = self;
    _displayController.searchResultsDataSource = self;
    _displayController.searchResultsDelegate   = self;
    
    
    _displayController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
    
    //noSearchData
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = [UIImage imageNamed:@"enjoy_choosePlace.png"];
    CGFloat width,height;
    width = 60 *SCREEN_W /320;
    height = 60 *SCREEN_W /320;
    imgV.tag = 4500;
    imgV.hidden = YES;
    imgV.frame = CGRectMake( (SCREEN_W - width) /2 , 100, width, height);
    [_displayController.searchResultsTableView addSubview: imgV];
    
    //emptyLabel
    UILabel *emptyLabel = [[UILabel alloc]init];
    emptyLabel.frame = CGRectMake(0, CGRectGetMaxY(imgV.frame) +20, SCREEN_W, 16);
    emptyLabel.font = [UIFont systemFontOfSize:16];
    emptyLabel.tag = 4600;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.hidden = YES;
    [_displayController.searchResultsTableView addSubview: emptyLabel];
}

- (void)initSearch
{
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    _search.language = MAMapLanguageZhCN;

}


-(void)createChooseResultTable{
    
    //结果TableView
    CGFloat y = CGRectGetMaxY(_mapView.frame);
    chooseOriginY = y;
    _chooseResultTable = [[UITableView alloc]init];
    _chooseResultTable.delegate = self;
    _chooseResultTable.dataSource = self;
    _chooseResultTable.tag = 2008;
    _chooseResultTable.rowHeight = 52;
    _chooseResultTable.tableFooterView = [[UIView alloc]init];
    
    [self.view addSubview:_chooseResultTable];
    [_chooseResultTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.top.equalTo(_mapView.mas_bottom);
        make.left.and.right.mas_equalTo(0);
    }];
    
      [self addLoadMoreTableFooterView];
}

- (void)addLoadMoreTableFooterView {
    
    __weak typeof(self)weakSelf = self;
    _chooseResultTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
 
         [weakSelf loadMoreData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 2008){
        return poiResultArr.count;
    }else{
        return searchResultArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:tipCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    WeJuBarPoi *poi =  nil;
    if(tableView.tag == 2008){
        if(poiResultArr)
        poi = [poiResultArr objectAtIndex:indexPath.row];
        
        if(poi == lastMarkPOI){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else{
        if(searchResultArr)
        poi = [searchResultArr objectAtIndex:indexPath.row];
    }
  
    
    cell.textLabel.text = poi.placeTitle ;
    cell.detailTextLabel.text = poi.address;
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag != 2008){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        WeJuBarPoi *poi = [searchResultArr objectAtIndex: indexPath.row];
        
        [self confirmAddress:poi];
    }
    
    else{
    
        lastMarkCell.accessoryType = UITableViewCellAccessoryNone;
        lastMarkPOI = [poiResultArr objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastMarkCell = cell;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        bClickCellMakeMoveFlag = YES;
        WeJuBarPoi *poi = [poiResultArr objectAtIndex: indexPath.row];
        
        [self clear];
        
        WJPOIAnnotation *annotation  = [[WJPOIAnnotation alloc]initWithPOI:poi];
        
        [_mapView addAnnotations:@[annotation]];
        [_mapView selectAnnotation:annotation animated:YES]; //动画选中标注
        
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.latitude, poi.longitude) animated:YES]; // 动画移动中心
       
        [self locationIconJump]; //跳动
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self beginLoadingAnimation];
    isClickSearchTag = YES;
    isClickCancelTag = NO;
    
    /* 清除annotation. */
    [self clear];
    
    //POI检索
    [self searchPOIWithKey:searchBar.text];
    
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
 
    [_searchBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.and.right.mas_equalTo(0);
        make.height.equalTo(@44);
    }];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    customerSearchText = _searchBar.text;
 
        if(isShowResultTag== 1)  //在result表格的时候，防止拖动时候，searchBar在顶部
            if(isClickSearchTag){
                
            }
}

//change
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    customerSearchText = _searchBar.text;
}

//取消搜索的时候，调整相应的UI回到原有状态
-(void)hideSearchController{
    
    [_searchBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
        make.height.equalTo(@44);
    }];
}

//点击取消按钮，searchBar 回到原来位置。
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    isClickCancelTag = YES;
    isClickSearchTag = NO;
    [self hideSearchController];
}

//隐藏键盘
-(void)keyboardWillHide:(NSNotification *)notification{
    
    if(customerSearchText.length == 0){ //文字内容0，或是搜索表格还未出现。
        [self hideSearchController];
    }
}

#pragma -mark UISearchDisplayDelegate
//隐藏resulttable
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    isShowResultTag=0;
    if(searchResultArr.count > 0){
        [searchResultArr removeAllObjects];
        [self reloadSearchResultTableView];
    }
}

////显示resulttable
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    isShowResultTag=1;
    
    [self showBeforeSearchView];
}

-(void)showBeforeSearchView
{
    UITableView *tableView1 = _displayController.searchResultsTableView;
    for( UIView *subview in tableView1.subviews ) {
        if( [subview class] == [UILabel class] ) {
            UILabel *lbl = (UILabel*)subview;
            lbl.text = @"";
        }
    }
    UIImageView *emptyImage = (UIImageView *) [_displayController.searchResultsTableView viewWithTag:4500];
    emptyImage.hidden = NO;
    
    UILabel *emptyLabel = (UILabel *) [_displayController.searchResultsTableView viewWithTag:4600];
    emptyLabel.hidden = NO;
    emptyLabel.text =  NSLocalizedString(@"Search Your Need Place", @"搜索你要查找的地点关键字");
}

-(void)reloadSearchResultTableView
{
    if(searchResultArr.count >0){
        UIImageView *emptyImage = (UIImageView *) [_displayController.searchResultsTableView viewWithTag:4500];
        emptyImage.hidden = YES;
        UILabel *emptyLabel = (UILabel *) [_displayController.searchResultsTableView viewWithTag:4600];
        emptyLabel.hidden = YES;
        
    }else{
        //无数据的情况下，自定义按钮显示
        UIImageView *emptyImage = (UIImageView *) [_displayController.searchResultsTableView viewWithTag:4500];
        emptyImage.hidden = NO;
        UILabel *emptyLabel = (UILabel *) [_displayController.searchResultsTableView viewWithTag:4600];
        emptyLabel.hidden = NO;
        emptyLabel.text =  NSLocalizedString(@"Search No Results", @"暂无相关结果");
    }
    
    [_displayController.searchResultsTableView reloadData];
    _displayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _displayController.searchResultsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - AMapSearchDelegate

/* 当请求发生错误时，会调用代理的此方法. */
- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"requestPOI :%@, error :%@", request, error);
}


/* POI 搜索. */
- (void)searchPOIWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapPOIKeywordsSearchRequest *place = [[AMapPOIKeywordsSearchRequest alloc] init];
    place.keywords = key;
    place.requireExtension = YES;//设置成YES，返回信息详细，较费流量
    place.city = targetCity;
    [_search AMapPOIKeywordsSearch:place];
}


-(void)jjPoiSearchPlaceAround
{
    if(bClickCellMakeMoveFlag){
        bClickCellMakeMoveFlag = NO;
    }else{
        [self beginLoadingAnimation];
        [self searchPoiByCenterCoordinate];
    }
}


//反编码搜索，得到地理位置
-(void)searchPoiByReGeo{
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    if(targetPoi == nil){
        regeoRequest.location = [AMapGeoPoint  locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    }else{
        regeoRequest.location = [AMapGeoPoint  locationWithLatitude:_moveTargetLocation.coordinate.latitude longitude:_moveTargetLocation.coordinate.longitude];
    }
    regeoRequest.requireExtension = YES;
    
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
}

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = [AMapGeoPoint locationWithLatitude:_moveTargetLocation.coordinate.latitude longitude:_moveTargetLocation.coordinate.longitude];
    request.keywords = @"大学|俱乐部|公园|运动|娱乐|电影|广场|酒店|KTV|体育";
   
    request.radius              = 2000;
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.page                = currentPoiPage;
    request.requireExtension    = YES;
    
    [_search AMapPOIAroundSearch:request];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        targetPoi =  [[WeJuBarPoi alloc]init];
        targetPoi.placeTitle = @"[位置]";
        targetPoi.address =  response.regeocode.formattedAddress;
        targetPoi.latitude = request.location.latitude;
        targetPoi.longitude = request.location.longitude;
        targetPoi.bPositionFlag = YES;
        
        //在mapView移动的情况下（非表格点击），可能POI先回调，这里做处理，
        if(bClickCellMakeMoveFlag == NO && bTargetPoiHasAddToPoiResultArr == NO ){
            if(poiResultArr.count <= 20){ //只在第一页做插入前的判断
                
                if(poiResultArr.count > 0){
                    WeJuBarPoi *firstPosition  = [poiResultArr objectAtIndex:0];
                    if(firstPosition.bPositionFlag){
                        return ;
                    }
                }
                
                [poiResultArr insertObject:targetPoi atIndex:0];
                lastMarkPOI = targetPoi; // 给新移动的位置标记
                lastMarkCell = [_chooseResultTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]]; //标记cell
                [_chooseResultTable reloadData];
            }
        }
    }
}


/* POI 搜索回调: 只有当位置新移动的时候. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    //搜索关键字
    if([request class] == [AMapPOIKeywordsSearchRequest class]){
        
        [searchResultArr removeAllObjects];
        //添加数据
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            
            WeJuBarPoi *poi =  [[WeJuBarPoi alloc]init];
            poi.placeTitle = obj.name;
            poi.address = [NSString stringWithFormat:@"%@%@%@%@",obj.province,obj.city,obj.district,obj.address];
            poi.longitude = obj.location.longitude;
            poi.latitude = obj.location.latitude;
            [searchResultArr addObject:poi];
        }];
        
        [self stopLoadingAnimation];
        
        //翻页了也要刷新表格
        [self reloadSearchResultTableView];
       
    }
    
    //搜索周边
    if([request class] == [AMapPOIAroundSearchRequest class]){
        
        [_chooseResultTable.mj_footer endRefreshing];
        
        if (response.pois.count == 0)
        {
           [_chooseResultTable.mj_footer endRefreshingWithNoMoreData]; //没有更多
            return;
        }

        //等于第一页的时候，清空所有，并增加位置
        if(request.page == 1){
            [poiResultArr removeAllObjects];
            if(targetPoi){
                lastMarkPOI = targetPoi; // 给新移动的位置标记
                lastMarkCell = [_chooseResultTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]]; //标记cell
                [poiResultArr addObject:targetPoi];
                bTargetPoiHasAddToPoiResultArr = YES; //标识 新移动的位置已经添加到poi数组中了
            }
        }
        
        //添加数据
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
            
            WeJuBarPoi *poi =  [[WeJuBarPoi alloc]init];
            poi.placeTitle = obj.name;
            targetCity = obj.city;
            poi.address = [NSString stringWithFormat:@"%@%@%@%@",obj.province,obj.city,obj.district,obj.address];
            poi.longitude = obj.location.longitude;
            poi.latitude = obj.location.latitude;
            [poiResultArr addObject:poi];
        }];
        
        
        //判断是否还有下一页
        BOOL hasMore = (response.pois.count + request.page * 20 < response.count) ? YES : NO;
        if (hasMore)
        {
            
            [_chooseResultTable.mj_footer resetNoMoreData];//还有更多
        }
        else
        {
             [_chooseResultTable.mj_footer endRefreshingWithNoMoreData]; //没有更多
             currentPoiPage = 1; //重置到第一页，以便新位置移动时候加载第一页。
             bTargetPoiHasAddToPoiResultArr = NO;
        }
        
        //翻页了也要刷新表格
        [_chooseResultTable reloadData];
        
        //因为新的位置发生改变时（也就是在请求第一页时候），好的用户体验，表格需滑到顶部
        if(request.page == 1){
            [_chooseResultTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        [self stopLoadingAnimation];
    }
}


#pragma mark - MAMapViewDelegate
//经纬度发生改变的时候，获取用户位置。不停调用？
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if(updatingLocation)
    {
    }
}


//区域改变
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    CLLocationDegrees latitude = _mapView.centerCoordinate.latitude;
    CLLocationDegrees longitude = _mapView.centerCoordinate.longitude;
    _moveTargetLocation=[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    //逆地理得到位置地址
    [self searchPoiByReGeo]; //这里不能像周边一样，控制 bClickCellMoveFlag 可能会影响到周边（因为不知道谁的回调速度快）
    
    currentPoiPage = 1;
    
    //搜索周边
    [self jjPoiSearchPlaceAround];
    
    
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[WJPOIAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"pointAnnotion"];
        //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}


#pragma mark - Methods

//location Icon 弹跳
-(void)locationIconJump{
 
    [[PRTween sharedInstance] removeTweenOperation:_activeTweenOperation];
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:155 endValue:170 duration:1.5];
    _activeTweenOperation = [[PRTween sharedInstance] addTweenPeriod:period target:self selector:@selector(updateLocationIcon:) timingFunction:&PRTweenTimingFunctionBounceOut];
    [[PRTween sharedInstance] addTweenOperation:_activeTweenOperation];
}

- (void)updateLocationIcon:(PRTweenPeriod*)period {
    if ([period isKindOfClass:[PRTweenCGPointLerpPeriod class]]) {
        _locationImageView.center = [(PRTweenCGPointLerpPeriod*)period tweenedCGPoint];
    } else {
        _locationImageView.frame = CGRectMake(_locationImageView.frame.origin.x, period.tweenedValue, _locationImageView.frame.size.width, _locationImageView.frame.size.height);
    }
}

//停止加载动画
-(void)stopLoadingAnimation
{
    if (iLoadingState == 1)
    {
        iLoadingState = 2;
    }
}

//开始加载动画
-(void)beginLoadingAnimation{
    [self.view bringSubviewToFront:loadingIconImageView];
    reloading = YES;
    iLoadingState = 1;
    [self showLoadingIconAnimation];
}


- (void)showLoadingIconAnimation
{
    [self cancelRotationTimer];
    loadingIconImageView.alpha = 1;
    rotationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(loadingIconAnimation)];
    rotationDisplayLink.frameInterval = 2;
    [rotationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)cancelRotationTimer
{
    if(rotationDisplayLink)
    {
        [rotationDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        rotationDisplayLink = nil;
    }
}

- (void)loadingIconAnimation
{
    fRotation += 20;
    CGAffineTransform at = CGAffineTransformMakeRotation(-fRotation * M_PI / 180);
    [loadingIconImageView setTransform:at];
    if (iLoadingState == 2)
    {
        loadingIconImageView.alpha -= 0.1;
        if (loadingIconImageView.alpha <= 0)
        {
            [self cancelRotationTimer];
            
            //重置状态
            iLoadingState = 0;
            reloading = NO;
            
            fRotation = 0;
            CGAffineTransform at = CGAffineTransformMakeRotation(-fRotation);
            [loadingIconImageView setTransform:at];
            
            loadingIconImageView.alpha = 0;
        }
    }
}


//加载更多
-(void)loadMoreData{
    currentPoiPage ++;
    [self jjPoiSearchPlaceAround];
}

/* 清除annotation. */
- (void)clear
{
    [_mapView removeAnnotations:_mapView.annotations];
}

//返回到用户定位位置
-(void)backUserLocation{
    
    [self clear];
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude) animated:YES]; // 动画移动中心
}

/* 逆地理编码 搜索. */
- (void)reverseGeocoding
{
    
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    double lat =  _currentLocation.coordinate.latitude ;
    double lng  = _currentLocation.coordinate.longitude;
    
    request.location = [AMapGeoPoint locationWithLatitude:lat longitude:lng];
    
    [_search AMapReGoecodeSearch:request];
}


//确认
-(void)choosePoi{
    [self confirmAddress:lastMarkPOI];
}

-(void)confirmAddress:(WeJuBarPoi *) choosePlace{
    
    //test
    [SVProgressHUD showInfoWithStatus:choosePlace.placeTitle];
    return;
    
    //实际业务中，选择地址之后，回到前一个页面。
//    [self.navigationController popViewControllerAnimated:NO];
//    if (_delegate && [_delegate conformsToProtocol:@protocol(MapPositionControllerDelegate)] && [_delegate respondsToSelector:@selector(onSelectedMapPosition:)]) {
//       
//        [_delegate onSelectedMapPosition:choosePlace];
//    }
}


- (void)initCompleteBlock
{
   __weak MapPositionController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            //如果为定位失败的error，则不进行annotation的添加
            if (error.code == AMapLocationErrorLocateFailed)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务未开启"
                                                                    message:@"需要你在手机设置开启定位服务以使用精确位置"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil, nil];
                alertView.tag = 1010;
                [alertView show];
                
                return;
            }
        }
        
        //得到定位信息，添加annotation
        if (location)
        {
            
            weakSelf.currentLocation = location;
             [weakSelf setMapCenter:weakSelf.currentLocation.coordinate];
        }
    };
}

-(void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    //设置允许在后台定位
    //[self.locationManager setAllowsBackgroundLocationUpdates:YES];
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
    
    [self reGeocodeAction];
}


- (void)cleanUpAction
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];
}

- (void)reGeocodeAction
{
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

//设置中心点坐标
- (void)setMapCenter:(CLLocationCoordinate2D)coordinate {
//    if (coordinate.latitude >= -90.0 && coordinate.latitude <= 90.0 && coordinate.longitude >= -180.0 && coordinate.longitude <= 180.0) {
    
        MACoordinateSpan span = MACoordinateSpanMake(0.025, 0.025);
        MACoordinateRegion region = MACoordinateRegionMake(coordinate, span);
       _mapView.region = [_mapView regionThatFits:region]; //要使region变动，所以使用这个，不使用setCenterCoordinate  //[_mapView setCenterCoordinate:coordinate animated:YES];
    
        [_mapView setZoomLevel:17.2 animated:NO];
    
  //  }
}
-(void)dealloc{
    
    [self cleanUpAction];
    
    self.completionBlock = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
