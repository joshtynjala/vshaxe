package builders;

/** sounds like an RTS... **/
class BaseBuilder implements IBuilder {
    var cli:CliTools;
    var defaults:Project;
    var project:Project;

    public function new(cli:CliTools, defaults:Project, project:Project) {
        this.cli = cli;
        this.defaults = defaults;
        this.project = project;
    }

    public function build(cliArgs:CliArguments) {}

    function resolveHaxelib(name:String):Haxelib {
        for (lib in project.haxelibs)
            if (lib.name == name)
                return lib;
        for (lib in defaults.haxelibs)
            if (lib.name == name)
                return lib;
        return null;
    }

    function resolveTarget(name:String):Target {
        for (target in project.targets)
            if (target.name == name)
                return target;
        for (target in defaults.targets)
            if (target.name == name)
                return target;
        return null;
    }

    function resolveTargets(names:Array<String>):Array<Target> {
        return names.map(resolveTarget);
    }

    function resolveTargetHxml(target:Target, debug:Bool, flatten:Bool, display:Bool, recurse:Bool = true):Hxml {
        var hxmls:Array<Hxml> = [target.args];
        if (debug && target.debug != null) hxmls.push(target.debug.args);
        if (display && target.display != null) hxmls.push(target.display.args);

        if (recurse) {
            var inherited = resolveInherited(target);
            if (inherited != null) {
                hxmls.push(resolveTargetHxml(inherited, debug, flatten, display, false));
            }
        }

        if (flatten) {
            var dependencyHxmls = resolveTargets(target.targetDependencies.get()).map(resolveTargetHxml.bind(_, debug, flatten, display));
            hxmls = hxmls.concat(dependencyHxmls);
        }

        return mergeHxmls(hxmls, flatten);
    }

    function resolveInherited(target:Target):Target {
        if (target.inherit != null) return resolveTarget(target.inherit);
        if (project.inherit != null) return resolveTarget(project.inherit);
        return null;
    }

    function mergeHxmls(hxmls:Array<Hxml>, flatten:Bool):Hxml {
        var classPaths = [];
        var defines = [];
        var haxelibs = [];
        var debug = false;
        var output = null;
        var deadCodeElimination = null;
        var noInline = false;
        var main = null;
        var packageName = null;

        function merge(hxml:Hxml) {
            if (hxml == null) return;
            var rawClassPaths = hxml.classPaths.get();
            if (flatten) rawClassPaths = rawClassPaths.map(function(cp) return haxe.io.Path.join([hxml.workingDirectory, cp]));
            classPaths = classPaths.concat(rawClassPaths);
            defines = defines.concat(hxml.defines.get());
            haxelibs = haxelibs.concat(hxml.haxelibs.get());
            debug = debug || hxml.debug;
            if (hxml.output != null) output = hxml.output; // just use the most recent one I guess?
            if (hxml.deadCodeElimination != null) deadCodeElimination = hxml.deadCodeElimination;
            if (hxml.noInline == true) noInline = true;
            if (hxml.main != null) main = hxml.main;
            if (hxml.packageName != null) packageName = hxml.packageName;
        }

        for (hxml in hxmls) merge(hxml);

        return {
            workingDirectory: '',
            classPaths: classPaths,
            defines: defines,
            haxelibs: haxelibs,
            debug: debug,
            output: output,
            deadCodeElimination: deadCodeElimination,
            noInline: noInline,
            main: main,
            packageName: packageName
        };
    }
}