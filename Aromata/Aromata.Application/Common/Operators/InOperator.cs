using System.Collections;
using System.Linq.Expressions;
using Gridify.Syntax;

namespace Aromata.Application.Common.Operators;

public class InOperator : IGridifyOperator
{
    public string GetOperator() => "#in";
    
    public Expression<OperatorParameter> OperatorHandler() =>
        (prop, value) => ((IEnumerable<string>)value).Contains(prop.ToString());

}