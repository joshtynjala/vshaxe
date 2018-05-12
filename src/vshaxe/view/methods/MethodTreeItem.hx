package vshaxe.view.methods;

class MethodTreeItem extends TreeItem {
    final context:ExtensionContext;
    final timer:Timer;
    final isRoot:Bool;
    final name:String;

    public final children:Array<MethodTreeItem>;
    public final method:String;

    public function new(context:ExtensionContext, timer:Timer, method:String, isRoot:Bool) {
        super("");
        this.context = context;
        this.timer = timer;
        this.isRoot = isRoot;
        this.method = method;

        name = formatName();
        label = formatLabel();
        tooltip = formatTooltip();
        id = '$method $name ${timer.info}';
        if (timer.children == null) {
            children = null;
            collapsibleState = None;
        } else {
            children = timer.children.map(MethodTreeItem.new.bind(context, _, method, false));
            collapsibleState = Expanded;
        }
        if (isRoot) {
            iconPath = {
                light: context.asAbsolutePath("resources/light/method.svg"),
                dark: context.asAbsolutePath("resources/dark/method.svg")
            };
        }
    }

    public function collapse() {
        if (collapsibleState != None) {
            collapsibleState = Collapsed;
        }
    }

    function formatName():String {
        var name = if (isRoot) method else timer.name;
        if (timer.info != "") {
            name = '${timer.info}.$name';
        }
        return name;
    }

    function formatLabel():String {
        var seconds = truncate(timer.time, 5);
        var percent = truncate(timer.percentTotal, 4);
        var label = '$name - ${seconds}s';
        if (!isRoot) {
            label += ' ($percent%)';
        }
        return label;
    }

    function formatTooltip():String {
        var now = Date.now();
        var timestamp = '[${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}]';
        return '$timestamp ${timer.calls} calls - ${truncate(timer.time, 7)}s';
    }

    function truncate(f:Float, precision:Int) {
        return Std.string(f).substr(0, precision);
    }
}
