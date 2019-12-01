unit untInterfaceController;

interface

uses
   System.Generics.Defaults, System.Generics.Collections, System.SysUtils, System.IOUtils, System.Classes, System.StrUtils,
   System.Variants;

type
   TInterfaceControllerFactory<I: IInterface> = reference to function(): I;
   TInterfaceControllerFactoryGuid<I: IInterface> = reference to function(const guid: TGUID): I;

   IInterfaceControllerFactory = interface
      ['{6BC680EA-2832-48F2-BE01-E08195F20FA9}']
   end;

   IInterfaceControllerFactory<I: IInterface> = interface(IInterfaceControllerFactory)
      ['{A84E37B9-0550-4694-BD67-2D50307F8A75}']
      function Get(): I;
   end;

   TInterfaceWrapper = class
   private
      intf: IInterface;
   public
      constructor Create(intf: IInterface);
      destructor Destroy; override;
   end;

   IInterfaceControllerDll = interface
      ['{EE674631-4117-40EE-9BD7-2CB13BEC58F8}']
      function HasInterface(const guid: TGUID): Boolean;
      function CreateInterface(const guid: TGUID): IInterface;
      procedure Load();
   end;

   TInterfaceControllerDllHasInterface = reference to function(const guid: TGUID): Boolean;
   IInterfaceControllerDllCreateInterface = reference to function(const guid: TGUID): IInterface;

   TGenericInterfaceControllerDll = class(TInterfacedObject, IInterfaceControllerDll)
   private
      interfaceControllerDllHasInterface: TInterfaceControllerDllHasInterface;
      interfaceControllerDllCreateInterface: IInterfaceControllerDllCreateInterface;
   public
      constructor Create(const interfaceControllerDllHasInterface: TInterfaceControllerDllHasInterface;
         const interfaceControllerDllCreateInterface: IInterfaceControllerDllCreateInterface);
      destructor Destroy; override;
      function HasInterface(const guid: TGUID): Boolean;
      function CreateInterface(const guid: TGUID): IInterface;
      procedure Load;
   end;

   IInterfaceController = interface
      ['{E307C08A-1BD3-4FA9-AD46-9C8104198F78}']
      function CreateInterface(const guid: TGUID): IInterface; overload;
      function HasInterface(const guid: TGUID): Boolean; overload;
   end;

   TOnDllExceptionPrc = reference to procedure (const E: Exception; const strFileName: string);

   SingletonAttribute = class(TCustomAttribute);

   TInterfaceController = class
   private
      class var lock: TObject;
      class var prcOnDllException: TOnDllExceptionPrc;

      class var dicRegistries: TObjectDictionary<string, TObject>;
      class var lstClearSingleton: TList<TProc>;
      class var dicDllCache: TDictionary<TGUID, string>;

      class var lstPaths: TList<string>;
      class var dicDllsController: TDictionary<string, IInterfaceControllerDll>;

      class var dicComparers: TObjectDictionary<string, TObject>;

      class var dicInterfacesNames: TDictionary<TGUID, string>;

      class var interfaceController: IInterfaceController;

      class var lstOnDllLoad: TList<TProc>;

      class function GetDllFiles(): TList<string>;
      class function GetDll(const strFileName: string): IInterfaceControllerDll;
      class function GetModuleName(): string;

      class function ExecuteLocked<T>(const fnc: TFunc<T>): T; overload;
      class procedure ExecuteLocked(const prc: TProc); overload;
      class function GetInterfaceName(const guid: TGUID): string; overload;
      class function GetInterfaceName<I: IInterface>(): string; overload;
      class function HasInterfaceDll(const guid: TGUID): Boolean;
      class function CreateInterfaceDll( const guid: TGUID): IInterface;
      class procedure SetLibPaths();
   public
      class constructor Create();
      class destructor Destroy;

      class procedure RegisterImplementation<I: IInterface>(const interfaceControllerFactory: TInterfaceControllerFactory<I>); overload;
      class procedure RegisterImplementation<T; I: IInterface>(const key: T; const interfaceControllerFactory: TInterfaceControllerFactory<I>); overload;

      class procedure RegisterImplementation<I: IInterface>(const interfaceControllerFactory: IInterfaceControllerFactory<I>); overload;
      class procedure RegisterImplementation<T; I: IInterface>(const key: T; const interfaceControllerFactory: IInterfaceControllerFactory<I>); overload;

      class procedure RegisterImplementation<I: IInterface>(const cls: TClass); overload;
      class procedure RegisterImplementation<T; I: IInterface>(const key: T; const cls: TClass); overload;

      class procedure RegisterClass(const cls: TClass); overload;
      class procedure RegisterClass<T>(const key: T; const cls: TClass); overload;

      class function CreateInterface<I: IInterface>(): I; overload;
      class function CreateInterface<T; I: IInterface>(const key: T): I; overload;

      class function CreateInterface(const guid: TGUID): IInterface; overload;
      class function CreateInterface<T>(const key: T; const guid: TGUID): IInterface; overload;

      class function HasInterface<I: IInterface>(): Boolean; overload;
      class function HasInterface<T; I: IInterface>(const key: T): Boolean; overload;

      class function HasInterface(const guid: TGUID): Boolean; overload;
      class function HasInterface<T>(const key: T; const guid: TGUID): Boolean; overload;

      class procedure AddScanPath(const strPath: string);
      class procedure RegisterInterfaceController(const interfaceController: IInterfaceController);
      class procedure RegisterComparer<T>(const interfaceControllerComparer: TEqualityComparison<T>; const interfaceControllerHasher: THasher<T>);

      class procedure ClearSingleton();

      class procedure AddOnDllLoad(const prc: TProc);
      class procedure SetOnGetDllException(const prc: TOnDllExceptionPrc);
   end;

   EInterfaceControllerException = class(Exception);
   EInterfaceControllerUnAssignedLock = class(EInterfaceControllerException);
   EInterfaceControllerUnAssignedSingleton = class(EInterfaceControllerException);
   EInterfaceControllerUnAssignedRegistries = class(EInterfaceControllerException);
   EInterfaceControllerNotRegistred = class(EInterfaceControllerException);
   EInterfaceControllerInterfaceWithOutGUID = class(EInterfaceControllerException);
   ELoadLibraryNull = class(Exception);
   EInterfaceControllerDllInvalid = class(Exception);

   TInterfaceControllerFactoryAdapter<I: IInterface> = class(TInterfacedObject, IInterfaceControllerFactory<I>)
   private
      interfaceControllerFactory: TInterfaceControllerFactory<I>;
      instancia: I;
      singleton: Boolean;
   public
      constructor Create(const interfaceControllerFactory: TInterfaceControllerFactory<I>);
      function Get(): I;
   end;

   TInterfaceControllerFactoryAdapterGuid<I: IInterface> = class(TInterfacedObject, IInterfaceControllerFactory<I>)
   private
      guid: TGUID;
      interfaceControllerFactoryGuid: TInterfaceControllerFactoryGuid<I>;
      instancia: I;
      singleton: Boolean;
   public
      constructor Create(const guid: TGUID; const interfaceControllerFactoryGuid: TInterfaceControllerFactoryGuid<I>);
      function Get(): I;
   end;

   function GetInterfaceController(const interfaceController: IInterfaceController): IInterfaceControllerDll; stdcall;

implementation

uses
   System.TypInfo, System.Rtti, Winapi.Windows;

type
   TDll = class(TInterfacedObject)
   private
      strFileName: string;
      intHandle: NativeUInt;
   public
      constructor Create(const strFileName: string); reintroduce; virtual;
      destructor Destroy; override;
   end;

   TGetInterfaceController = function(const interfaceController: IInterfaceController): IInterfaceControllerDll; stdcall;
   TInterfaceControllerDllDestroyer = procedure (); stdcall;

   TInterfaceControllerDll = class(TDll, IInterfaceControllerDll)
   private
      interfaceControllerDll: IInterfaceControllerDll;
      interfaceControllerDllDestroyer: TInterfaceControllerDllDestroyer;
      GetInterfaceController: TGetInterfaceController;
   public
      constructor Create(const strFileName: string); override;
      destructor Destroy; override;
      function HasInterface(const guid: TGUID): Boolean;
      function CreateInterface(const guid: TGUID): IInterface;
      procedure Load;
   end;

   TInterfaceControllerExport = class(TInterfacedObject, IInterfaceController)
   public
      function CreateInterface(const guid: TGUID): IInterface; overload;
      function HasInterface(const guid: TGUID): Boolean; overload;
   end;

   { TInterfaceController }

class constructor TInterfaceController.Create;
begin
   TInterfaceController.lock := TObject.Create;
   TInterfaceController.dicRegistries := TObjectDictionary<string, TObject>.Create([doOwnsValues]);
   TInterfaceController.lstClearSingleton := TList<TProc>.Create;;
   TInterfaceController.lstPaths := TList<string>.Create();
   TInterfaceController.dicDllsController := TObjectDictionary<string, IInterfaceControllerDll>.Create();
   TInterfaceController.dicDllCache := TDictionary<TGUID, string>.Create();;
   TInterfaceController.dicComparers := TObjectDictionary<string, TObject>.Create();
   TInterfaceController.dicInterfacesNames := TDictionary<TGUID, string>.Create();
   TInterfaceController.lstOnDllLoad := TList<TProc>.Create;
   TInterfaceController.prcOnDllException := procedure (const E: Exception; const strFileName: string)
      begin
      end;
   SetLibPaths();
end;

class function TInterfaceController.CreateInterface(const guid: TGUID): IInterface;
begin
   Result := ExecuteLocked<IInterface>(function (): IInterface
      begin
         Result := nil;
         var strKey := GetTypeName(TypeInfo(TGUID));
         var obj: TObject;
         if dicRegistries.TryGetValue(strKey, obj) then
         begin
            var dicObj := obj as TObjectDictionary<TGUID, TObject>;
            var dicObjValue: TObject;

            if dicObj.TryGetValue(guid, dicObjValue) then
            begin
               var dicFactory := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>(dicObjValue);
               var interfaceControllerFactory: IInterfaceControllerFactory<IInterface>;

               if dicFactory.TryGetValue(guid, interfaceControllerFactory) then
               begin
                  if Supports(interfaceControllerFactory.Get, guid, Result) then
                     Exit;
               end;
            end;
         end;

         if not Assigned(Result) then
         begin
            Result := CreateInterfaceDll(guid);
            if Assigned(Result) then
               Exit;
         end;

         if (not Assigned(Result)) and Assigned(interfaceController) and (interfaceController.HasInterface(guid)) then
         begin
            Result := interfaceController.CreateInterface(guid);
            if Assigned(Result) then
               Exit;
         end;

         raise EInterfaceControllerNotRegistred.CreateFmt('Interface %s não registrada', [GetInterfaceName(guid)]);
      end);
end;

class function TInterfaceController.CreateInterface<I>: I;
begin
   var guid := GetTypeData(TypeInfo(I))^.GUID();
   var intF := CreateInterface(guid);
   if not Supports(intF, guid, Result) then
      raise EInterfaceControllerNotRegistred.CreateFmt('Interface %s não registrada', [GetInterfaceName<I>()]);
end;

class function TInterfaceController.CreateInterface<T, I>(
  const key: T): I;
begin
   Result := ExecuteLocked<I>(function (): I
      begin
         Result := nil;
         var strKey := GetTypeName(TypeInfo(T));
         var obj: TObject;
         if dicRegistries.TryGetValue(strKey, obj) then
         begin
            var dicObj := TObjectDictionary<T, TObject>(obj);
            var dicObjValue: TObject;

            if dicObj.TryGetValue(key, dicObjValue) then
            begin
               var guid := GetTypeData(TypeInfo(I)).GUID;
               var interfaceControllerFactory: IInterfaceControllerFactory<IInterface>;
               if TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>(dicObjValue).TryGetValue(guid, interfaceControllerFactory) then
               begin
                  if Supports(interfaceControllerFactory.Get, guid, Result) then
                     Exit;
               end;
            end;
         end;

         raise EInterfaceControllerNotRegistred.CreateFmt('Interface <%s>%s não registrada', [TValue.From<T>(key).ToString(), GetInterfaceName<I>()]);
      end);
end;

class function TInterfaceController.CreateInterface<T>(const key: T;
  const guid: TGUID): IInterface;
begin
   Result := ExecuteLocked<IInterface>(function (): IInterface
      begin
         Result := nil;
         var strKey := GetTypeName(TypeInfo(T));
         var obj: TObject;
         if dicRegistries.TryGetValue(strKey, obj) then
         begin
            var dicObj := TObjectDictionary<T, TObject>(obj);
            var dicObjValue: TObject;

            if dicObj.TryGetValue(key, dicObjValue) then
            begin
               var dicValue := TDictionary<TGUID,IInterfaceControllerFactory<IInterface>>(dicObjValue);
               var interfaceControllerFactory: IInterfaceControllerFactory<IInterface>;

               if dicValue.TryGetValue(guid, interfaceControllerFactory) then
               begin
                  if Supports(interfaceControllerFactory.Get(), guid, Result) then
                     Exit;
               end;
            end;
         end;

         raise EInterfaceControllerNotRegistred.CreateFmt('Interface <%s>%s não registrada', [TValue.From<T>(key).ToString(), GetInterfaceName(guid)]);
      end);
end;

class function TInterfaceController.CreateInterfaceDll(
  const guid: TGUID): IInterface;
begin
   Result := nil;
   var strDllFile: string;
   if dicDllCache.TryGetValue(guid, strDllFile) then
   begin
      var dll := GetDll(strDllFile);
      if Assigned(dll) then
      begin
         Result := dll.CreateInterface(guid);
         Exit;
      end;
   end;

   if not Assigned(Result) then
   begin
      var lst := GetDllFiles();
      try
         for var strDll in lst do
         begin
            var dll := GetDll(strDll);
            if Assigned(dll) and dll.HasInterface(guid) then
            begin
               Result := dll.CreateInterface(guid);
               Exit;
            end;
         end;
      finally
         if Assigned(lst) then FreeAndNil(lst)
      end;
   end;
end;

class destructor TInterfaceController.Destroy;
begin
   TInterfaceController.ClearSingleton;
   if Assigned(TInterfaceController.dicRegistries) then
      FreeAndNil(TInterfaceController.dicRegistries);
   if Assigned(TInterfaceController.lock) then
      FreeAndNil(TInterfaceController.lock);
   if Assigned(TInterfaceController.lstPaths) then
      FreeAndNil(TInterfaceController.lstPaths);
   if Assigned(TInterfaceController.dicDllsController) then
      FreeAndNil(TInterfaceController.dicDllsController);
   if Assigned(TInterfaceController.dicDllCache) then
      FreeAndNil(TInterfaceController.dicDllCache);
   if Assigned(TInterfaceController.dicComparers) then
      FreeAndNil(TInterfaceController.dicComparers);
   if Assigned(TInterfaceController.dicInterfacesNames) then
      FreeAndNil(TInterfaceController.dicInterfacesNames);
   if Assigned(TInterfaceController.lstOnDllLoad) then
      FreeAndNil(TInterfaceController.lstOnDllLoad);
   if Assigned(TInterfaceController.lstClearSingleton) then
      FreeAndNil(TInterfaceController.lstClearSingleton);
end;

class procedure TInterfaceController.ExecuteLocked(const prc: TProc);
begin
   if lock = nil then
      raise EInterfaceControllerUnAssignedLock.Create('lock = nil');
   if dicRegistries = nil then
      raise EInterfaceControllerUnAssignedRegistries.Create('dicRegistries = nil');

   if (lock <> nil) and MonitorEnter(lock) then
   begin
      try
         prc();
      finally
         MonitorExit(lock);
      end;
   end;
end;

class function TInterfaceController.ExecuteLocked<T>(
  const fnc: TFunc<T>): T;
begin
   if lock = nil then
      raise EInterfaceControllerUnAssignedLock.Create('lock = nil');
   if dicRegistries = nil then
      raise EInterfaceControllerUnAssignedRegistries.Create('dicRegistries = nil');

   if (lock <> nil) and MonitorEnter(lock) then
   begin
      try
         Result := fnc();
      finally
         MonitorExit(lock);
      end;
   end;
end;

class function TInterfaceController.GetDll(const strFileName: string): IInterfaceControllerDll;
begin
   Result := nil;
   if not dicDllsController.TryGetValue(strFileName, Result) then
   begin
      try
         Result := TInterfaceControllerDll.Create(strFileName) as IInterfaceControllerDll;
         dicDllsController.AddOrSetValue(strFileName, Result);
         Result.Load;
      except
         on E: Exception do
         begin
            Result := nil;
            prcOnDllException(E, strFileName);
         end;
      end;
   end;
end;

class function TInterfaceController.GetDllFiles(): TList<string>;
var
   sr: TSearchRec;
begin
   Result := TList<string>.Create;

   if ExtractFileExt(GetModuleName()).ToUpper() = '.dll'.ToUpper() then
      Exit;

   for var strDllPath in lstPaths do
   begin
      var strPathSearch := TPath.GetFullPath(strDllPath + '\*.*');
      if FindFirst(strPathSearch, faAnyFile, sr) = 0 then
      begin
         try
            repeat
               if MatchStr(sr.Name, ['.', '..']) then
                  Continue;
               var strPathDll := TPath.GetFullPath(strDllPath + '\' + sr.Name);
               if ExtractFileExt(strPathDll).ToUpper() = '.dll'.ToUpper() then
                  Result.Add(strPathDll);
            until FindNext(sr) <> 0;
         finally
            System.SysUtils.FindClose(sr);
         end;
      end;
   end;
end;

class function TInterfaceController.GetInterfaceName(
  const guid: TGUID): string;
begin
   if dicInterfacesNames.TryGetValue(guid, Result) then
      Exit;

   Result := GUIDToString(guid);

   var ctx := TRttiContext.Create;
   try
      var arrTypes: TArray<TRttiType> := ctx.GetTypes();
      for var ctxType in arrTypes do
      begin
         if ctxType is TRttiInterfaceType then
         begin
            var intFType := ctxType as TRttiInterfaceType;
            if intFType.GUID = guid then
            begin
               dicInterfacesNames.AddOrSetValue(guid, intFType.Name);
               Exit(intFType.Name);
            end;
         end;
      end;
   finally
      ctx.Free;
   end;
end;

class function TInterfaceController.GetInterfaceName<I>: string;
begin
   var guid := GetTypeData(TypeInfo(I))^.GUID();
   Result := GetInterfaceName(guid);
end;

class function TInterfaceController.GetModuleName: string;
var
  szFileName: array[0..MAX_PATH] of Char;
begin
  FillChar(szFileName, SizeOf(szFileName), #0);
  GetModuleFileName(hInstance, szFileName, MAX_PATH);
  Result := szFileName;
end;

class function TInterfaceController.HasInterface(const guid: TGUID): Boolean;
begin
   Result := ExecuteLocked<Boolean>(function (): Boolean
      begin
         var strKey := GetTypeName(TypeInfo(TGUID));
         var obj: TObject;
         Result := dicRegistries.TryGetValue(strKey, obj);
         if Result then
         begin
            var dicObj := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>(obj);
            Result := dicObj.ContainsKey(guid);
         end;

         if not Result then
         begin
            Result := HasInterfaceDll(guid);
            if Result then
               Exit;
         end;

         if not Result then
         begin
            Result := Assigned(interfaceController) and interfaceController.HasInterface(guid);
         end;

      end);
end;

class function TInterfaceController.HasInterface<I>: Boolean;
begin
   Result := ExecuteLocked<Boolean>(function (): Boolean
      begin
         var strKey := GetTypeName(TypeInfo(TGUID));
         var obj: TObject;
         Result := dicRegistries.TryGetValue(strKey, obj);
         var guid := GetTypeData(TypeInfo(I))^.GUID();

         if Result then
         begin
            var dicObj := TDictionary<TGUID, IInterfaceControllerFactory<I>>(obj);
            Result := dicObj.ContainsKey(guid);
            if Result then
               Exit;
         end;

         if not Result then
         begin
            Result := HasInterfaceDll(guid);
            if Result then
               Exit;
         end;

         if not Result then
         begin
            Result := Assigned(interfaceController) and interfaceController.HasInterface(guid);
         end;
      end);
end;

class function TInterfaceController.HasInterface<T, I>(
  const key: T): Boolean;
begin
   Result := ExecuteLocked<Boolean>(function (): Boolean
      begin
         var strKey := GetTypeName(TypeInfo(T));
         var obj: TObject;
         Result := dicRegistries.TryGetValue(strKey, obj);
         if Result then
         begin
            var dicObj := obj as TDictionary<T, IInterfaceControllerFactory<I>>;
            Result := dicObj.ContainsKey(key);
         end;

      end);
end;

class function TInterfaceController.HasInterface<T>(const key: T;
  const guid: TGUID): Boolean;
begin
   Result := ExecuteLocked<Boolean>(function (): Boolean
      begin
         var strKey := GetTypeName(TypeInfo(T));
         var obj: TObject;
         Result := dicRegistries.TryGetValue(strKey, obj);
         if Result then
         begin
            var dicObj := TDictionary<T, IInterfaceControllerFactory<IInterface>>(obj);
            Result := dicObj.ContainsKey(key);
         end;
      end);
end;

class function TInterfaceController.HasInterfaceDll(
  const guid: TGUID): Boolean;
begin
   Result := dicDllCache.ContainsKey(guid);

   if not Result then
   begin
      var lst := GetDllFiles();
      try
         for var strDll in lst do
         begin
            var dll := GetDll(strDll);
            if Assigned(dll) and (dll.HasInterface(guid)) then
            begin
               dicDllCache.AddOrSetValue(guid, strDll);
               Result := True;
               Exit;
            end;
         end;
      finally
         if Assigned(lst) then FreeAndNil(lst)
      end;
   end;
end;

class procedure TInterfaceController.AddOnDllLoad(const prc: TProc);
begin
   TInterfaceController.lstOnDllLoad.Add(prc);
end;

class procedure TInterfaceController.SetOnGetDllException(
  const prc: TOnDllExceptionPrc);
begin
   TInterfaceController.prcOnDllException := prc;
end;

class procedure TInterfaceController.AddScanPath(const strPath: string);
begin
   if not lstPaths.Contains(strPath) then
      lstPaths.Add(strPath);
end;

class procedure TInterfaceController.ClearSingleton;
begin
   for var p in lstClearSingleton do
   begin
      p();
   end;
end;

class procedure TInterfaceController.RegisterImplementation<I>(const interfaceControllerFactory: IInterfaceControllerFactory<I>);
begin
   RegisterImplementation<TGUID, I>(GetTypeData(TypeInfo(I))^.GUID(), interfaceControllerFactory);
end;

class procedure TInterfaceController.RegisterClass(const cls: TClass);
begin
   ExecuteLocked(procedure
      begin
         var interfaceTable := cls.GetInterfaceTable;
         if Assigned(interfaceTable) then
         begin
            for var i := 0 to interfaceTable^.EntryCount - 1 do
            begin
               var dicGuid := interfaceTable^.Entries[i].IID;
               var interfaceControllerFactory: TInterfaceControllerFactoryGuid<IInterface> := function(const guid: TGUID): IInterface
                  begin
                     var ctx := TRttiContext.Create;
                     try
                        var ctxType := ctx.GetType(cls);
                        var ctxTypeMethod := ctxType.GetMethod('Create');
                        if Assigned(ctxTypeMethod) and ctxTypeMethod.IsConstructor then
                        begin
                           var objResult := ctxTypeMethod.Invoke(cls, []).AsObject;
                           if not Supports(objResult, guid, Result) then
                              Result := nil;
                        end;
                     finally
                        ctx.Free;
                     end;
                  end;

               var strKey := GetTypeName(TypeInfo(TGUID));
               var obj: TObject;
               if not dicRegistries.TryGetValue(strKey, obj) then
               begin
                  var objComparer: TObject;
                  var comparer: IEqualityComparer<TGUID>;
                  if dicComparers.TryGetValue(strKey, objComparer) then
                  begin
                     comparer := TDelegatedEqualityComparer<TGUID>(objComparer);
                  end;

                  if not Assigned(comparer) then
                  begin
                     comparer := TEqualityComparer<TGUID>.Default();
                  end;

                  obj := TObjectDictionary<TGUID, TObject>.Create([doOwnsValues], comparer);
                  var dicGuidFactory := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>.Create();
                  (obj as TObjectDictionary<TGUID, TObject>).AddOrSetValue(dicGuid, dicGuidFactory);
                  dicRegistries.AddOrSetValue(strKey, obj);
               end;

               var dicObj := (obj as TObjectDictionary<TGUID, TObject>);
               var dicGuidFactoryObj: TObject;
               if not dicObj.TryGetValue(dicGuid, dicGuidFactoryObj) then
               begin
                  dicGuidFactoryObj := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>.Create();
                  dicObj.AddOrSetValue(dicGuid, dicGuidFactoryObj);
               end;

               TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>(dicGuidFactoryObj).AddOrSetValue(dicGuid,
                  TInterfaceControllerFactoryAdapterGuid<IInterface>.Create(dicGuid, interfaceControllerFactory));
            end;
         end;
      end);
end;

class procedure TInterfaceController.RegisterClass<T>(const key: T;
  const cls: TClass);
begin
   ExecuteLocked(procedure
      begin
         var interfaceTable := cls.GetInterfaceTable;
         if Assigned(interfaceTable) then
         begin
            for var i := 0 to interfaceTable^.EntryCount - 1 do
            begin
               var dicGuid := interfaceTable^.Entries[i].IID;
               var interfaceControllerFactory: TInterfaceControllerFactoryGuid<IInterface> := function(const guid: TGUID): IInterface
                  begin
                     var ctx := TRttiContext.Create;
                     try
                        var ctxType := ctx.GetType(cls);
                        var ctxTypeMethod := ctxType.GetMethod('Create');
                        if Assigned(ctxTypeMethod) and ctxTypeMethod.IsConstructor then
                        begin
                           var objResult := ctxTypeMethod.Invoke(cls, []).AsObject;
                           if not Supports(objResult, guid, Result) then
                              Result := nil;
                        end;
                     finally
                        ctx.Free;
                     end;
                  end;

               var strKey := GetTypeName(TypeInfo(T));
               var obj: TObject;
               if not dicRegistries.TryGetValue(strKey, obj) then
               begin
                  var objComparer: TObject;
                  var comparer: IEqualityComparer<T>;
                  if dicComparers.TryGetValue(strKey, objComparer) then
                  begin
                     comparer := TDelegatedEqualityComparer<T>(objComparer);
                  end;

                  if not Assigned(comparer) then
                  begin
                     comparer := TEqualityComparer<T>.Default();
                  end;

                  obj := TObjectDictionary<T, TObject>.Create([doOwnsValues], comparer);
                  var dicGuidFactory := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>.Create();
                  (obj as TObjectDictionary<T, TObject>).AddOrSetValue(key, dicGuidFactory);
                  dicRegistries.AddOrSetValue(strKey, obj);
               end;

               var dicObj := (obj as TObjectDictionary<T, TObject>);
               var dicGuidFactoryObj: TObject;
               if not dicObj.TryGetValue(key, dicGuidFactoryObj) then
               begin
                  dicGuidFactoryObj := TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>.Create();
                  dicObj.AddOrSetValue(key, dicGuidFactoryObj);
               end;

               TDictionary<TGUID, IInterfaceControllerFactory<IInterface>>(dicGuidFactoryObj).AddOrSetValue(dicGuid,
                  TInterfaceControllerFactoryAdapterGuid<IInterface>.Create(dicGuid, interfaceControllerFactory));
            end;
         end;
      end);
end;

class procedure TInterfaceController.RegisterComparer<T>(
  const interfaceControllerComparer: TEqualityComparison<T>;
  const interfaceControllerHasher: THasher<T>);
begin
   var valor := TDelegatedEqualityComparer<T>.Create(interfaceControllerComparer, interfaceControllerHasher);
   dicComparers.AddOrSetValue(GetTypeName(TypeInfo(T)), valor);
end;

class procedure TInterfaceController.RegisterImplementation<I>(const cls: TClass);
begin
   RegisterImplementation<TGUID, I>(GetTypeData(TypeInfo(I))^.GUID(), cls);
end;

class procedure TInterfaceController.RegisterImplementation<T, I>(
  const key: T; const cls: TClass);
begin
   ExecuteLocked(procedure
      begin
         var guid := GetTypeData(TypeInfo(I))^.GUID();
         if Supports(cls, guid) then
         begin
            var interfaceControllerFactory: TInterfaceControllerFactoryGuid<IInterface> := function(const guid: TGUID): IInterface
               begin
                  var ctx := TRttiContext.Create;
                  try
                     var ctxType := ctx.GetType(cls);
                     var ctxTypeMethod := ctxType.GetMethod('Create');
                     if Assigned(ctxTypeMethod) and ctxTypeMethod.IsConstructor then
                     begin
                        var objResult := ctxTypeMethod.Invoke(cls, []).AsObject;
                        if not Supports(objResult, guid, Result) then
                           Result := nil;
                     end;
                  finally
                     ctx.Free;
                  end;
               end;

            var strKey := GetTypeName(TypeInfo(T));
            var obj: TObject;
            if not dicRegistries.TryGetValue(strKey, obj) then
            begin
               var objComparer: TObject;
               var comparer: IEqualityComparer<T>;
               if dicComparers.TryGetValue(strKey, objComparer) then
               begin
                  comparer := TDelegatedEqualityComparer<T>(objComparer);
               end;

               if not Assigned(comparer) then
               begin
                  comparer := TEqualityComparer<T>.Default();
               end;

               obj := TDictionary<T,IInterfaceControllerFactory<I>>.Create(comparer);
               dicRegistries.AddOrSetValue(strKey, obj);
            end;

            var dicObj := (obj as TDictionary<T,IInterfaceControllerFactory<IInterface>>);
            dicObj.AddOrSetValue(key, TInterfaceControllerFactoryAdapterGuid<IInterface>.Create(guid, interfaceControllerFactory));
         end;
      end);
end;

class procedure TInterfaceController.RegisterImplementation<T, I>(
  const key: T; const interfaceControllerFactory: IInterfaceControllerFactory<I>);
begin
   ExecuteLocked(procedure
      begin
         var strKey := GetTypeName(TypeInfo(T));
         var obj: TObject;
         if not dicRegistries.TryGetValue(strKey, obj) then
         begin
            var objComparer: TObject;
            var comparer: IEqualityComparer<T>;
            if dicComparers.TryGetValue(strKey, objComparer) then
            begin
               comparer := TDelegatedEqualityComparer<T>(objComparer);
            end;

            if not Assigned(comparer) then
            begin
               comparer := TEqualityComparer<T>.Default();
            end;

            obj := TObjectDictionary<T, TObject>.Create([doOwnsValues], comparer);
            var dicGuidFactory := TDictionary<TGUID, IInterfaceControllerFactory<I>>.Create();
            (obj as TObjectDictionary<T, TObject>).AddOrSetValue(key, dicGuidFactory);
            dicRegistries.AddOrSetValue(strKey, obj);
         end;

         var dicObj := (obj as TObjectDictionary<T, TObject>);
         var dicGuidFactoryObj: TObject;
         if not dicObj.TryGetValue(key, dicGuidFactoryObj) then
         begin
            dicGuidFactoryObj := TDictionary<TGUID, IInterfaceControllerFactory<I>>.Create();
            dicObj.AddOrSetValue(key, dicGuidFactoryObj);
         end;

         var dicGuid := GetTypeData(TypeInfo(I)).GUID;
         TDictionary<TGUID, IInterfaceControllerFactory<I>>(dicGuidFactoryObj).AddOrSetValue(dicGuid, interfaceControllerFactory);
      end);
end;

class procedure TInterfaceController.RegisterImplementation<T, I>(
  const key: T; const interfaceControllerFactory: TInterfaceControllerFactory<I>);
begin
   RegisterImplementation<T, I>(key, TInterfaceControllerFactoryAdapter<I>.Create(interfaceControllerFactory) as IInterfaceControllerFactory<I>);
end;

class procedure TInterfaceController.RegisterInterfaceController(
  const interfaceController: IInterfaceController);
begin
   TInterfaceController.interfaceController := interfaceController;
end;

class procedure TInterfaceController.RegisterImplementation<I>(const interfaceControllerFactory: TInterfaceControllerFactory<I>);
begin
   RegisterImplementation<I>(TInterfaceControllerFactoryAdapter<I>.Create(interfaceControllerFactory) as IInterfaceControllerFactory<I>);
end;

class procedure TInterfaceController.SetLibPaths;
begin
   var strPath := ExtractFileDir(ParamStr(0));
   for var i := 1 to 3 do
   begin
      var strPathLib := strPath + '\libs';
      if TDirectory.Exists(strPathLib) then
      begin
         TInterfaceController.AddScanPath(strPathLib);
      end;

      try
         strPath := TDirectory.GetParent(strPath);
      except
         on E: Exception do
         begin
            Exit;
         end;
      end;
   end;
end;

{ TInterfaceWrapper }

constructor TInterfaceWrapper.Create(intf: IInterface);
begin
   inherited Create();
   Self.intf := intf;
end;

destructor TInterfaceWrapper.Destroy;
begin
   try
      intf := nil;
   except
   end;
   inherited Destroy;
end;

{ TInterfaceControllerFactoryAdapter<I> }

constructor TInterfaceControllerFactoryAdapter<I>.Create(const interfaceControllerFactory: TInterfaceControllerFactory<I>);
begin
   inherited Create();
   Self.interfaceControllerFactory := interfaceControllerFactory;
   Self.instancia := nil;
   Self.singleton := True;
end;

function TInterfaceControllerFactoryAdapter<I>.Get: I;
begin
   Result := instancia;
   if not Assigned(Result) then
   begin
      Result := interfaceControllerFactory();
      if singleton and (Result is TObject) then
      begin
         var obj := Result as TObject;
         var context := TRttiContext.Create;
         try
            var rttiType := context.GetType(obj.ClassType);
            var attrs: TArray<TCustomAttribute> := rttiType.GetAttributes();
            for var attr in attrs do
            begin
               if attr is SingletonAttribute then
               begin
                  instancia := Result;
                  TInterfaceController.lstClearSingleton.Add(procedure ()
                     begin
                        instancia := nil;
                     end);
                  Exit;
               end;
            end;

            singleton := False;
         finally
            context.Free;
         end;
      end;
   end;
end;

{ TDll }

constructor TDll.Create(const strFileName: string);
begin
   inherited Create();
   Self.strFileName := strFileName;
   intHandle := LoadLibrary(PWideChar(strFileName));
   if intHandle = 0 then
   begin
      var intLastError := GetLastError();
      raise ELoadLibraryNull.CreateFmt('Falha ao carregar a dll %s [%d][%s]', [strFileName, intLastError, SysErrorMessage(intLastError)]);
   end;

end;

destructor TDll.Destroy;
begin
   if intHandle <> 0 then
      FreeLibrary(intHandle);
   inherited Destroy;
end;

{ TInterfaceControllerDll }

constructor TInterfaceControllerDll.Create(const strFileName: string);
begin
   inherited Create(strFileName);
   @GetInterfaceController := GetProcAddress(intHandle, PWideChar('GetInterfaceController'));

   if (@GetInterfaceController = nil) then
      raise EInterfaceControllerDllInvalid.CreateFmt('A dll %s é inválida', [strFileName]);

   interfaceControllerDll := GetInterfaceController(TInterfaceControllerExport.Create());
end;

function TInterfaceControllerDll.CreateInterface(const guid: TGUID): IInterface;
begin
   Result := interfaceControllerDll.CreateInterface(guid);
end;

destructor TInterfaceControllerDll.Destroy;
begin
   interfaceControllerDll := nil;

   @interfaceControllerDllDestroyer := GetProcAddress(intHandle, PWideChar('InterfaceControllerDllDestroyer'));
   if @interfaceControllerDllDestroyer <> nil then
      interfaceControllerDllDestroyer();

   inherited Destroy;
end;

function TInterfaceControllerDll.HasInterface(const guid: TGUID): Boolean;
begin
   Result := interfaceControllerDll.HasInterface(guid);
end;

procedure TInterfaceControllerDll.Load;
begin
   interfaceControllerDll.Load;
end;

{ TGenericInterfaceControllerDll }

constructor TGenericInterfaceControllerDll.Create(const interfaceControllerDllHasInterface: TInterfaceControllerDllHasInterface;
const interfaceControllerDllCreateInterface: IInterfaceControllerDllCreateInterface);
begin
   inherited Create();
   Self.interfaceControllerDllHasInterface := interfaceControllerDllHasInterface;
   Self.interfaceControllerDllCreateInterface := interfaceControllerDllCreateInterface;
end;

function TGenericInterfaceControllerDll.CreateInterface(const guid: TGUID): IInterface;
begin
   var interfaceController := TInterfaceController.interfaceController;
   try
      TInterfaceController.RegisterInterfaceController(nil);
      Result := interfaceControllerDllCreateInterface(guid);
   finally
      TInterfaceController.RegisterInterfaceController(interfaceController);
   end;
end;

destructor TGenericInterfaceControllerDll.Destroy;
begin
   inherited Destroy;
end;

function TGenericInterfaceControllerDll.HasInterface(const guid: TGUID): Boolean;
begin
   var interfaceController := TInterfaceController.interfaceController;
   try
      TInterfaceController.RegisterInterfaceController(nil);
      Result := interfaceControllerDllHasInterface(guid);
   finally
      TInterfaceController.RegisterInterfaceController(interfaceController);
   end;
end;

procedure TGenericInterfaceControllerDll.Load;
begin
   for var prc in TInterfaceController.lstOnDllLoad do
   begin
      prc();
   end;
end;

{ TInterfaceControllerExport }

function TInterfaceControllerExport.CreateInterface(
  const guid: TGUID): IInterface;
begin
   Result := TInterfaceController.CreateInterface(guid);
end;

function TInterfaceControllerExport.HasInterface(
  const guid: TGUID): Boolean;
begin
   Result := TInterfaceController.HasInterface(guid);
end;

function GetInterfaceController(const interfaceController: IInterfaceController): IInterfaceControllerDll;
begin
   TInterfaceController.RegisterInterfaceController(interfaceController);
   Result := TGenericInterfaceControllerDll.Create(
      function(const guid: TGUID): Boolean
      begin
         Result := TInterfaceController.HasInterface(guid);
      end,
      function(const guid: TGUID): IInterface
      begin
         Result := TInterfaceController.CreateInterface(guid);
      end);
end;

{ TInterfaceControllerFactoryAdapterGuid<I> }

constructor TInterfaceControllerFactoryAdapterGuid<I>.Create(
  const guid: TGUID; const interfaceControllerFactoryGuid: TInterfaceControllerFactoryGuid<I>);
begin
   inherited Create();
   Self.guid := guid;
   Self.interfaceControllerFactoryGuid := interfaceControllerFactoryGuid;
   Self.instancia := nil;
   Self.singleton := True;
end;

function TInterfaceControllerFactoryAdapterGuid<I>.Get: I;
begin
   Result := instancia;
   if not Assigned(Result) then
   begin
      Result := interfaceControllerFactoryGuid(guid);
      if singleton and (Result is TObject) then
      begin
         var obj := Result as TObject;
         var context := TRttiContext.Create;
         try
            var rttiType := context.GetType(obj.ClassType);
            var attrs: TArray<TCustomAttribute> := rttiType.GetAttributes();
            for var attr in attrs do
            begin
               if attr is SingletonAttribute then
               begin
                  instancia := Result;
                  TInterfaceController.lstClearSingleton.Add(procedure ()
                     begin
                        instancia := nil;
                     end);
                  Exit;
               end;
            end;

            singleton := False;
         finally
            context.Free;
         end;
      end;
   end;
end;

end.
