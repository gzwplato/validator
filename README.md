# Simple Validation Library for Object Pascal Applications

The purpose of this library is to make ridiculously easy to validate values in your Object Pascal application. You can specify validation rules in few minutes, avoiding having to write a lot of if-else structures and without significantly compromising performance.

### Supported Components for Now

**Standard**

* Edit
* ComboBox
* Memo 

**Data Controls**

* DBEdit
* DBCombobox
* DBMemo

### Usage

* Download the file Validator.pas and add it to the uses section of your form.

* Be sure to call the procedure InitValidator once, passing a reference to the current form. Example:

    <pre>InitValidator(Self);</pre>

* Call the procedure AddValidation for each component you want to validate, passing a referece for the component and the rules for validation. The message associated with each validation rule should be specified after the asterisk character (*). Examples:

    <pre>
    AddValidation(
        Edit1, 
        [
            'required *This field is required',
            'min_length:5 *This field must have at least 5 characters',
            'max_length:10 *This field must have at most 10 characters'
        ]
    );</pre>
    
    <pre>
    AddValidation(
        Edit2, 
        [
            'required *This field is required',
            'numeric *This field must have only digits'
        ]
    );</pre>

* Then, call the Validate function, which will return True if there is no validation error, or False otherwise:
 
    <pre>
    if Validate then
        ShowMessage('The data have been successfully validated');
    </pre>

* Finally, call the procedure DestroyValidator:

    <pre>DestroyValidator;</pre>

### Rule reference

Rule          | Parameter | Description                                                                                                        | Example
------------- | --------- | ------------------------------------------------------------------------------------------------------------------ | -------
required      | No        | Returns False if the component value is empty.                                                                     |  
matches       | Yes       | Returns False if the component value does not match the one in the parameter.                                      | matches[Edit1]
min_length    | Yes       | Returns False if the component value is shorter then the parameter value.                                          | min_length:5
max_length    | Yes       | Returns False if the component value is longer then the parameter value.                                           | max_length:15
exact_length  | Yes       | Returns False if the component value is not exactly the parameter value.                                           | exact_length:7
greater_than  | Yes       | Returns False if the component value is less than the parameter value or not numeric.                              | greater_than:10
less_than     | Yes       | Returns False if the component value is greater than the parameter value or not numeric.                           | less_than:50
alpha         | No        | Returns False if the component value contains anything other than alphabetical characters.                         |
alpha_numeric | No        | Returns False if the component value contains anything other than alpha-numeric characters.                        |
alpha_dash    | No        | Returns False if the component value contains anything other than alpha-numeric characters, underscores or dashes. |
numeric       | No        | Returns False if the component value contains anything other than numeric characters.                              |
integer       | No        | Returns False if the component value contains anything other than an integer.                                      |
decimal       | No        | Returns False if the component value contains anything other than a decimal number.                                |
valid_cpf     | No        | Returns False if the component value isn't a valid CPF (Cadastro de Pessoa Física)                                 |

### Contributing

For comments and suggestions, send an email to leonardo.mcapetta@gmail.com

### Version History

**1.0.0** (Thursday, 20 August 2015)

* Initial public release.
