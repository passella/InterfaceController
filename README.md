### Features

- Control inversion management, capable of managing implementations in the same executable or even dll implementations;

#### Example:

How to call:

    ShowMessage(TInterfaceController.CreateInterface<IMyInterface>().Get());
    
Interface:

	type
		IMyInterface = interface
		['{F6D3CC02-D95C-49B0-ADBF-D6210567D96E}']

		function Get(): WideString;
	end;

How to implement:

	unit untMyInterface;

	interface

	implementation

	uses
	   untIMyInterface, untInterfaceController, Winapi.Windows, System.SysUtils;

	type
	   [Singleton]
	   TMyInterface = class(TInterfacedObject, IMyInterface)
	   private
		  function GetModuleName: string;
	   public
		  function Get: WideString;
	   end;

	   { TMyInterface }

	function TMyInterface.Get: WideString;
	begin
	   Result := Format('Hello from [%s]', [GetModuleName()]);
	end;

	function TMyInterface.GetModuleName: string;
	var
	   szFileName: array [0 .. MAX_PATH] of WideChar;
	begin
	   FillChar(szFileName, SizeOf(szFileName), #0);
	   GetModuleFileName(hInstance, szFileName, MAX_PATH);
	   Result := szFileName;
	end;

	initialization
	   TInterfaceController.RegisterClass(TMyInterface);

	end.
