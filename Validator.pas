unit Validator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, StdCtrls, Controls;

var
  //Stores the rules for validations
  rls: array of array of String;
  //Used by Split procedure
  //Avoids the overhead of creating a new list for each call
  aux1, aux2: TStringList;
  //Reference for the form containing the components
  frm: TForm;

{Validator routines}
procedure InitValidator(form: TForm);
procedure AddValidation(component: TComponent; rules: array of String);
function Validate: Boolean;
procedure DestroyValidator;

{Validate functions}
function Required(var component: TComponent): Boolean;
function Matches(var component1, component2: TComponent): Boolean;
function MinLength(var component: TComponent; min_length: Integer): Boolean;
function MaxLength(var component: TComponent; max_length: Integer): Boolean;
function ExactLength(var component: TComponent; exact_length: Integer): Boolean;
function GreaterThan(var component: TComponent; value: Integer): Boolean;
function LessThan(var component: TComponent; value: Integer): Boolean;
function IsAlpha(var component: TComponent): Boolean;
function IsAlphaNumeric(var component: TComponent): Boolean;
function IsAlphaDash(var component: TComponent): Boolean;
function IsNumeric(var component: TComponent): Boolean;
function IsInteger(var component: TComponent): Boolean;
function IsDecimal(var component: TComponent): Boolean;
function ValidCpf(var component: TComponent): Boolean;

{Auxiliar functions}
function Split(str: String; var list: TStringList; delimiter: Char = ','): TStringList;
function GetText(var component: TComponent): String;

implementation

{Validator routines}

procedure InitValidator(form: TForm);
begin
  frm := form;
  aux1 := TStringList.Create;
  aux2 := TStringList.Create;
end;

procedure AddValidation(component: TComponent; rules: array of String);
var
  i: Integer;
begin
  if not (component is TWinControl)  then
  begin
    raise Exception.Create('Component type not supported');
  end;

  SetLength(rls, Length(rls)+1);
  SetLength(rls[Length(rls)-1], 1 + Length(rules));

  rls[Length(rls)-1][0] := component.Name;

  for i := 0 to Length(rules)-1 do
    rls[Length(rls)-1][i+1] := rules[i];
end;

function Validate: Boolean;
var
  i, j: Integer;
  component, component2: TComponent;
  rule, msg: String;
begin
  for i := 0 to Length(rls)-1 do
  begin
    component := frm.FindComponent(rls[i][0]);

    if component = nil then
    begin
      raise Exception.Create('Component not found: ' + rls[i][0]);
    end;

    for j := 1 to Length(rls[i])-1 do
    begin
      Result := False;

      Split(rls[i][j], aux1, '*');
      rule := Trim(aux1.Strings[0]);

      if aux1.Count > 1 then
        msg := Trim(aux1.Strings[1])
      else
        msg := '';

      if (rule = 'required') and (not Required(component)) then
        Break

      else
      if Pos('matches', rule) <> 0 then
      begin
        component2 := frm.FindComponent(Trim(Split(rule, aux2, ':').Strings[1]));
        if not Matches(component, component2) then
          Break;
      end

      else
      if (Pos('min_length', rule) <> 0) and
         (not MinLength(component, StrToInt(Trim(Split(rule, aux2, ':').Strings[1])))) then
        Break

      else
      if (Pos('max_length', rule) <> 0) and
         (not MaxLength(component, StrToInt(Trim(Split(rule, aux2, ':').Strings[1])))) then
        Break

      else
      if (Pos('exact_length', rule) <> 0) and
         (not ExactLength(component, StrToInt(Trim(Split(rule, aux2, ':').Strings[1])))) then
        Break

      else
      if (Pos('greater_than', rule) <> 0) and
         (not GreaterThan(component, StrToInt(Trim(Split(rule, aux2, ':').Strings[1])))) then
        Break

      else
      if (Pos('less_than', rule) <> 0) and
         (not LessThan(component, StrToInt(Trim(Split(rule, aux2, ':').Strings[1])))) then
        Break

      else
      if (rule = 'integer') and (not IsInteger(component)) then
        Break

      else
      if (rule = 'alpha') and (not IsAlpha(component)) then
        Break

      else
      if (rule = 'alpha_numeric') and (not IsAlphaNumeric(component)) then
        Break

      else
      if (rule = 'alpha_dash') and (not IsAlphaDash(component)) then
        Break

      else
      if (rule = 'numeric') and (not IsNumeric(component)) then
        Break

      else
      if (rule = 'decimal') and (not IsDecimal(component)) then
        Break

      else
      if (rule = 'valid_cpf') and (not ValidCpf(component)) then
        Break;

      Result := True;
    end;

    if not Result then
    begin
      MessageDlg('', msg, mtError, [mbOK], '');
      (component as TWinControl).SetFocus;
      Exit;
    end;
  end;
end;

procedure DestroyValidator;
begin
  SetLength(rls, 0);
  aux1.Free;
  aux2.Free;
end;


{Validate functions}

function Required(var component: TComponent): Boolean;
begin
  if component is TCustomEdit then
    Result := Trim((component as TCustomEdit).Text) <> EmptyStr
  else if component is TCustomComboBox then
    Result := (component as TCustomComboBox).ItemIndex <> -1;
end;

function Matches(var component1, component2: TComponent): Boolean;
begin
  Result := GetText(component1) = GetText(component2);
end;

function MinLength(var component: TComponent; min_length: Integer): Boolean;
begin
  Result := Length(GetText(component)) >= min_length;
end;

function MaxLength(var component: TComponent; max_length: Integer
  ): Boolean;
begin
  Result := Length(GetText(component)) <= max_length;
end;

function ExactLength(var component: TComponent; exact_length: Integer
  ): Boolean;
begin
  Result := Length(GetText(component)) = exact_length
end;

function GreaterThan(var component: TComponent; value: Integer
  ): Boolean;
var
  value_: Real;
begin
  try
    value_ := StrToFloat(GetText(component));
  except on E: Exception do
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := value_ > value;
end;

function LessThan(var component: TComponent; value: Integer
  ): Boolean;
var
  value_: Real;
begin
  try
    value_ := StrToFloat(GetText(component));
  except on E: Exception do
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := value_ < value;
end;

function IsAlpha(var component: TComponent): Boolean;
var
  str: String;
  i: Integer;
begin
  str := GetText(component);

  for i := 1 to Length(str) do
  begin
    if not (str[i] in ['a'..'z', 'A'..'Z']) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function IsAlphaNumeric(var component: TComponent): Boolean;
var
  str: String;
  i: Integer;
begin
  str := GetText(component);

  for i := 1 to Length(str) do
  begin
    if not (str[i] in ['a'..'z', 'A'..'Z', '0'..'9']) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function IsAlphaDash(var component: TComponent): Boolean;
var
  str: String;
  i: Integer;
begin
  str := GetText(component);

  for i := 1 to Length(str) do
  begin
    if not (str[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-']) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function IsNumeric(var component: TComponent): Boolean;
var
  str: String;
  i: Integer;
begin
  str := GetText(component);

  for i := 1 to Length(str) do
  begin
    if not (str[i] in ['0'..'9']) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

function IsInteger(var component: TComponent): Boolean;
begin
  try
    StrToInt64(GetText(component));
  except on E: Exception do
  begin
    Result := False;
    Exit;
  end;
  end;

  Result := True;
end;

function IsDecimal(var component: TComponent): Boolean;
var
  str: String;
begin
  try
    StrToFloat(GetText(component));
  except on E: Exception do
  begin
    Result := False;
    Exit;
  end;
  end;

  Result := True;
end;

function ValidCpf(var component: TComponent): Boolean;
var
  cpf: String;
  i, soma, digito: Integer;
  valid: Boolean;
begin
  cpf := GetText(component);

  //The string length must be 11
  if Length(cpf) <> 11 then
  begin
    Result := False;
    Exit;
  end;

  //Accept only digits
  try
    StrToInt64(cpf);
  except on E: Exception do
  begin
    Result := False;
    Exit;
  end;
  end;

  //Avoid CPFs with all the same digits
  valid := False;

  for i := 1 to Length(cpf)-1 do
  begin
    if cpf[i] <> cpf[i+1] then
    begin
      valid := True;
      Break;
    end;
  end;

  if not valid then
  begin
     Result := False;
     Exit;
  end;

  //Verifies the first check digit
  soma := 0;
  for i := 10 downto 2 do
  begin
    soma := soma + i * StrToInt(cpf[11 - i]);
  end;

  if soma mod 11 < 2 then
     digito := 0
  else
     digito := 11 - soma mod 11;

  if digito <> StrToInt(cpf[10]) then
  begin
     Result := False;
     Exit;
  end;

  //Verifies the second check digit
  soma := 0;
  for i := 11 downto 2 do
  begin
    soma := soma + i * StrToInt(cpf[12 - i]);
  end;

  if soma mod 11 < 2 then
     digito := 0
  else
     digito := 11 - soma mod 11;

  if digito <> StrToInt(cpf[11]) then
  begin
     Result := False;
     Exit;
  end;

  Result := True;
end;

{Auxiliar functions}

function Split(str: String; var list: TStringList; delimiter: Char): TStringList;
begin
  list.Clear;
  ExtractStrings([delimiter], [], PChar(str),list);
  Result := list;
end;

function GetText(var component: TComponent): String;
begin
  if component is TCustomEdit then
    Result := Trim((component as TCustomEdit).Text)
  else if component is TCustomComboBox then
    Result := Trim((component as TCustomComboBox).Text);
end;

end.

