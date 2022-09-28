
import { Serializer, Deserializer } from '../serde/mod.ts';
import { BcsSerializer, BcsDeserializer } from '../bcs/mod.ts';
import { Optional, Seq, Tuple, ListTuple, unit, bool, int8, int16, int32, int64, int128, uint8, uint16, uint32, uint64, uint128, float32, float64, char, str, bytes } from '../serde/mod.ts';

import * as DiemTypes from '../diemTypes/mod.ts';

/**
 * Structured representation of a call into a known Move script.
 */
export abstract class ScriptCall {
}


export class ScriptCallVariantSetMessage extends ScriptCall {

constructor (public message: bytes) {
  super();
}

}
/**
 * Structured representation of a call into a known Move script function.
 */
export abstract class ScriptFunctionCall {
}


export class ScriptFunctionCallVariantCreateNft extends ScriptFunctionCall {

constructor (public content_uri: bytes) {
  super();
}

}

export class ScriptFunctionCallVariantInitializeNftCollection extends ScriptFunctionCall {

constructor (public nft_type: DiemTypes.TypeTag) {
  super();
}

}

export class ScriptFunctionCallVariantSetMessage extends ScriptFunctionCall {

constructor (public message_bytes: bytes) {
  super();
}

}

export class ScriptFunctionCallVariantTransfer extends ScriptFunctionCall {

constructor (public nft_type: DiemTypes.TypeTag, public to: DiemTypes.AccountAddress, public creator: DiemTypes.AccountAddress, public creation_num: uint64) {
  super();
}

}

export interface TypeTagDef {
  type: Types;
  arrayType?: TypeTagDef;
  name?: string;
  moduleName?: string;
  address?: string;
  typeParams?: TypeTagDef[];
}

export interface ArgDef {
  readonly name: string;
  readonly type: TypeTagDef;
  readonly choices?: string[];
  readonly mandatory?: boolean;
}

export interface ScriptDef {
  readonly stdlibEncodeFunction: (...args: any[]) => DiemTypes.Script;
  readonly stdlibDecodeFunction: (script: DiemTypes.Script) => ScriptCall;
  readonly codeName: string;
  readonly description: string;
  readonly typeArgs: string[];
  readonly args: ArgDef[];
}

export interface ScriptFunctionDef {
  readonly stdlibEncodeFunction: (...args: any[]) => DiemTypes.TransactionPayload;
  readonly description: string;
  readonly typeArgs: string[];
  readonly args: ArgDef[];
}

export enum Types {
  Boolean,
  U8,
  U64,
  U128,
  Address,
  Array,
  Struct
}


export class Stdlib {
  private static fromHexString(hexString: string): Uint8Array { return new Uint8Array(hexString.match(/.{1,2}/g)!.map((byte) => parseInt(byte, 16)));}

  /**

   */
  static encodeSetMessageScript(message: Uint8Array): DiemTypes.Script {
    const code = Stdlib.SET_MESSAGE_CODE;
    const tyArgs: Seq<DiemTypes.TypeTag> = [];
    const args: Seq<DiemTypes.TransactionArgument> = [new DiemTypes.TransactionArgumentVariantU8Vector(message)];
    return new DiemTypes.Script(code, tyArgs, args);
  }

  static decodeSetMessageScript(script: DiemTypes.Script): ScriptCallVariantSetMessage {
    return new ScriptCallVariantSetMessage(
      (script.args[0] as DiemTypes.TransactionArgumentVariantU8Vector).value
    );
  }

  /**

   */
  static encodeCreateNftScriptFunction(content_uri: Uint8Array): DiemTypes.TransactionPayload {
    const tyArgs: Seq<DiemTypes.TypeTag> = [];
    var serializer = new BcsSerializer();
    serializer.serializeBytes(content_uri);
    const content_uri_serialized: bytes = serializer.getBytes();
    const args: Seq<bytes> = [content_uri_serialized];
    const module_id: DiemTypes.ModuleId = new DiemTypes.ModuleId(new DiemTypes.AccountAddress([[122], [193], [190], [132], [229], [60], [172], [191], [134], [251], [188], [45], [228], [177], [151], [201]]), new DiemTypes.Identifier("TestNFT"));
    const function_name: DiemTypes.Identifier = new DiemTypes.Identifier("create_nft");
    const script = new DiemTypes.ScriptFunction(module_id, function_name, tyArgs, args);
    return new DiemTypes.TransactionPayloadVariantScriptFunction(script);
  }

  /**
   * Script function wrapper of initialize()
   */
  static encodeInitializeNftCollectionScriptFunction(nft_type: DiemTypes.TypeTag): DiemTypes.TransactionPayload {
    const tyArgs: Seq<DiemTypes.TypeTag> = [nft_type];
    const args: Seq<bytes> = [];
    const module_id: DiemTypes.ModuleId = new DiemTypes.ModuleId(new DiemTypes.AccountAddress([[122], [193], [190], [132], [229], [60], [172], [191], [134], [251], [188], [45], [228], [177], [151], [201]]), new DiemTypes.Identifier("NFTStandard"));
    const function_name: DiemTypes.Identifier = new DiemTypes.Identifier("initialize_nft_collection");
    const script = new DiemTypes.ScriptFunction(module_id, function_name, tyArgs, args);
    return new DiemTypes.TransactionPayloadVariantScriptFunction(script);
  }

  /**

   */
  static encodeSetMessageScriptFunction(message_bytes: Uint8Array): DiemTypes.TransactionPayload {
    const tyArgs: Seq<DiemTypes.TypeTag> = [];
    var serializer = new BcsSerializer();
    serializer.serializeBytes(message_bytes);
    const message_bytes_serialized: bytes = serializer.getBytes();
    const args: Seq<bytes> = [message_bytes_serialized];
    const module_id: DiemTypes.ModuleId = new DiemTypes.ModuleId(new DiemTypes.AccountAddress([[122], [193], [190], [132], [229], [60], [172], [191], [134], [251], [188], [45], [228], [177], [151], [201]]), new DiemTypes.Identifier("Message"));
    const function_name: DiemTypes.Identifier = new DiemTypes.Identifier("set_message");
    const script = new DiemTypes.ScriptFunction(module_id, function_name, tyArgs, args);
    return new DiemTypes.TransactionPayloadVariantScriptFunction(script);
  }

  /**
   * Transfer the non-fungible token `nft` with GUID identifiable by `creator` and `creation_num`
   * Transfer from `account` to `to`
   */
  static encodeTransferScriptFunction(nft_type: DiemTypes.TypeTag, to: DiemTypes.AccountAddress, creator: DiemTypes.AccountAddress, creation_num: bigint): DiemTypes.TransactionPayload {
    const tyArgs: Seq<DiemTypes.TypeTag> = [nft_type];
    var serializer = new BcsSerializer();
    to.serialize(serializer);
    const to_serialized: bytes = serializer.getBytes();
    var serializer = new BcsSerializer();
    creator.serialize(serializer);
    const creator_serialized: bytes = serializer.getBytes();
    var serializer = new BcsSerializer();
    serializer.serializeU64(creation_num);
    const creation_num_serialized: bytes = serializer.getBytes();
    const args: Seq<bytes> = [to_serialized, creator_serialized, creation_num_serialized];
    const module_id: DiemTypes.ModuleId = new DiemTypes.ModuleId(new DiemTypes.AccountAddress([[122], [193], [190], [132], [229], [60], [172], [191], [134], [251], [188], [45], [228], [177], [151], [201]]), new DiemTypes.Identifier("NFTStandard"));
    const function_name: DiemTypes.Identifier = new DiemTypes.Identifier("transfer");
    const script = new DiemTypes.ScriptFunction(module_id, function_name, tyArgs, args);
    return new DiemTypes.TransactionPayloadVariantScriptFunction(script);
  }

  static decodeCreateNftScriptFunction(script_fun: DiemTypes.TransactionPayload): ScriptFunctionCallVariantCreateNft {
  if (script_fun instanceof DiemTypes.TransactionPayloadVariantScriptFunction) {
      var deserializer = new BcsDeserializer(script_fun.value.args[0]);
      const content_uri: Uint8Array = deserializer.deserializeBytes();

      return new ScriptFunctionCallVariantCreateNft(
        content_uri
      );
    } else {
      throw new Error("Transaction payload not a script function payload")
    }
  }

  static decodeInitializeNftCollectionScriptFunction(script_fun: DiemTypes.TransactionPayload): ScriptFunctionCallVariantInitializeNftCollection {
  if (script_fun instanceof DiemTypes.TransactionPayloadVariantScriptFunction) {
      return new ScriptFunctionCallVariantInitializeNftCollection(
        script_fun.value.ty_args[0]
      );
    } else {
      throw new Error("Transaction payload not a script function payload")
    }
  }

  static decodeSetMessageScriptFunction(script_fun: DiemTypes.TransactionPayload): ScriptFunctionCallVariantSetMessage {
  if (script_fun instanceof DiemTypes.TransactionPayloadVariantScriptFunction) {
      var deserializer = new BcsDeserializer(script_fun.value.args[0]);
      const message_bytes: Uint8Array = deserializer.deserializeBytes();

      return new ScriptFunctionCallVariantSetMessage(
        message_bytes
      );
    } else {
      throw new Error("Transaction payload not a script function payload")
    }
  }

  static decodeTransferScriptFunction(script_fun: DiemTypes.TransactionPayload): ScriptFunctionCallVariantTransfer {
  if (script_fun instanceof DiemTypes.TransactionPayloadVariantScriptFunction) {
      var deserializer = new BcsDeserializer(script_fun.value.args[0]);
      const to: DiemTypes.AccountAddress = DiemTypes.AccountAddress.deserialize(deserializer);

      var deserializer = new BcsDeserializer(script_fun.value.args[1]);
      const creator: DiemTypes.AccountAddress = DiemTypes.AccountAddress.deserialize(deserializer);

      var deserializer = new BcsDeserializer(script_fun.value.args[2]);
      const creation_num: bigint = deserializer.deserializeU64();

      return new ScriptFunctionCallVariantTransfer(
        script_fun.value.ty_args[0],
        to,
        creator,
        creation_num
      );
    } else {
      throw new Error("Transaction payload not a script function payload")
    }
  }

  static SET_MESSAGE_CODE = Stdlib.fromHexString('a11ceb0b0400000005010002030205050705070c1408201000000001000100020c0a0200074d6573736167650b7365745f6d6573736167657ac1be84e53cacbf86fbbc2de4b197c9000001040b000b01110002');

  static ScriptArgs: {[name: string]: ScriptDef} = {
    SetMessage: {
      stdlibEncodeFunction: Stdlib.encodeSetMessageScript,
      stdlibDecodeFunction: Stdlib.decodeSetMessageScript,
      codeName: 'SET_MESSAGE',
      description: "",
      typeArgs: [],
      args: [
    {name: "message", type: {type: Types.Array, arrayType: {type: Types.U8}}}
      ]
    },
  }

  static ScriptFunctionArgs: {[name: string]: ScriptFunctionDef} = {

                CreateNft: {
      stdlibEncodeFunction: Stdlib.encodeCreateNftScriptFunction,
      description: "",
      typeArgs: [],
      args: [
        {name: "content_uri", type: {type: Types.Array, arrayType: {type: Types.U8}}}
      ]
    },
                

                InitializeNftCollection: {
      stdlibEncodeFunction: Stdlib.encodeInitializeNftCollectionScriptFunction,
      description: " Script function wrapper of initialize()",
      typeArgs: ["nft_type"],
      args: [
        
      ]
    },
                

                SetMessage: {
      stdlibEncodeFunction: Stdlib.encodeSetMessageScriptFunction,
      description: "",
      typeArgs: [],
      args: [
        {name: "message_bytes", type: {type: Types.Array, arrayType: {type: Types.U8}}}
      ]
    },
                

                Transfer: {
      stdlibEncodeFunction: Stdlib.encodeTransferScriptFunction,
      description: " Transfer the non-fungible token `nft` with GUID identifiable by `creator` and `creation_num`" + 
     " Transfer from `account` to `to`",
      typeArgs: ["nft_type"],
      args: [
        {name: "to", type: {type: Types.Address}}, {name: "creator", type: {type: Types.Address}}, {name: "creation_num", type: {type: Types.U64}}
      ]
    },
                
  }

}


export type ScriptDecoders = {
  User: {
    SetMessage: (type: string, message: DiemTypes.TransactionArgumentVariantU8Vector) => void;
    default: (type: keyof ScriptDecoders['User']) => void;
  };
};
