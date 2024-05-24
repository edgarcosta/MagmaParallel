// to allow f to be an UserProgram or Intrinsic
// FIXME: this should be supported in kernel...
function _Call(f, input, parameters, number_of_results)
  tmp := f;
  input_string := Join([Sprintf("input[%o]", i) : i->_ in input], ", ");
  if #parameters ge 1 then
    input_string cat:= ": ";
    input_string cat:= Join([Sprintf("%o:=parameters[%o, 2]", t[1], i) : i->t in parameters], ", ");
  end if;
  output_string := Join([Sprintf("__output_%o", i) : i in [1..number_of_results]], ", ");
  output_parser_string := Join([Sprintf("assigned __output_%o select __output_%o else None", i, i) : i in [1..number_of_results]], ", ");
  // The string that is used in the eval expression can refer to any variable that is in scope during the evaluation of the eval expression.
  // However, it is not possible for the expression to modify any of these variables.
  call_string := Sprintf("
  %o := tmp(%o);
  return [* %o *];", output_string, input_string, output_parser_string);
  try
    output := eval call_string;
    success_call := true;
  catch e
    print e;
    success_call := false;
    output := None;
  end try;
  return success_call, output;
end function;

intrinsic Call(f::UserProgram, input::Tup, number_of_results::RngIntElt : Parameters:=<> ) -> BoolElt, List
  { Call f on the input expecting return_nvals }
  return _Call(f, input, Parameters, number_of_results);
end intrinsic;

intrinsic Call(f::Intrinsic, input::Tup, number_of_results::RngIntElt : Parameters:=<> ) -> BoolElt, List
  { " } //"
  return _Call(f, input, Parameters, number_of_results);
end intrinsic;
