using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace csong.Mods;

public class CustomSong : IScriptMod {
    public bool ShouldRun(string path) => path == "res://Scenes/Entities/Props/prop_boombox.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens) {
        
        MultiTokenWaiter stateWaiter = new MultiTokenWaiter([
            t => t.Type == TokenType.PrVar,
            t => t is IdentifierToken {Name: "state"},
            t => t.Type == TokenType.OpAssign,
            t => t.Type == TokenType.OpSub,
            t => t is ConstantToken {Value: IntVariant {Value: 1}}

        ], allowPartialMatch: false);
        
        MultiTokenWaiter waiter = new MultiTokenWaiter([
            t => t.Type == TokenType.PrVar,
            t => t is IdentifierToken {Name: "new_state"},
            t => t.Type == TokenType.OpAssign,
            t => t is IdentifierToken {Name: "state"},
            t => t.Type == TokenType.OpAdd,
            t => t is ConstantToken {Value: IntVariant {Value: 1}}

        ], allowPartialMatch: false);

        foreach (var token in tokens) {
            if (waiter.Check(token)) {
                // found our match, return the original newline
                // then add our own code
                yield return new ConstantToken(new IntVariant(0));
            }else if(stateWaiter.Check(token)) {
                yield return new ConstantToken(new IntVariant(99));
            }
            else
            {
                yield return token;
            }
        }
    }
}