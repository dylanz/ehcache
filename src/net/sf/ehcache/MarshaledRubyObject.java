package net.sf.ehcache;

import java.io.Serializable;

public class MarshaledRubyObject implements Serializable {
  private byte[] bytes;

  public MarshaledRubyObject(byte[] bytes) {
    this.bytes = bytes;
  }

  public byte[] getBytes() {
    return this.bytes;
  }
}