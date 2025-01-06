using System.Linq.Expressions;
using Gridify.Syntax;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Common.Operators;

public class IlikeOperator : IGridifyOperator
{
    public string GetOperator() => "#=*";


    public Expression<OperatorParameter> OperatorHandler()
    {
        return (prop, value) => EF.Functions.ILike((string)prop, $"%{value}%");
    }
}